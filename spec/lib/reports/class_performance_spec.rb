require "rails_helper"

RSpec.describe Reports::ClassPerformance, type: :model do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:course) { create(:course, tenant:) }
  let!(:session) { create(:session, course:, tenant:) }
  let!(:lesson) { create(:lesson, session:, tenant:) }
  let!(:quiz) { create(:quiz, lesson:, tenant:) }

  it "ranqueia questões com mais respostas erradas" do
    q = build(:question, quiz:, tenant:)
    q.question_options.build(text: "A", correct: true, position: 0)
    q.question_options.build(text: "B", correct: false, position: 1)
    q.save!
    wrong = q.question_options.find_by!(correct: false)

    3.times do
      u = create(:user, :student, tenant:)
      create_submitted_answer(user: u, question: q, question_option: wrong)
    end

    result = ActsAsTenant.with_tenant(tenant) do
      Reports::ClassPerformance.new(tenant: tenant).call
    end

    expect(result.top_wrong.first.question.id).to eq(q.id)
    expect(result.top_wrong.first.wrong_count).to eq(3)
  end

  it "lista progresso por aluno no tenant" do
    create(:lesson, session:, tenant:, name: "Outra aula")
    LessonCompletion.create!(user: student, lesson:, quiz_completed: true, video_watched: true)

    result = ActsAsTenant.with_tenant(tenant) do
      Reports::ClassPerformance.new(tenant: tenant).call
    end

    row = result.student_rows.find { |r| r.user.id == student.id }
    expect(row.total).to eq(2)
    expect(row.completed).to eq(1)
  end

  it "inclui tempo total e tentativas por aluno" do
    q = build(:question, quiz:, tenant:)
    q.question_options.build(text: "A", correct: true, position: 0)
    q.question_options.build(text: "B", correct: false, position: 1)
    q.save!
    create_submitted_answer(user: student, question: q, question_option: q.question_options.find_by!(correct: true))

    result = ActsAsTenant.with_tenant(tenant) do
      Reports::ClassPerformance.new(tenant: tenant).call
    end

    row = result.student_rows.find { |r| r.user.id == student.id }
    expect(row.quiz_attempts_count).to eq(1)
    expect(row.quiz_time_seconds).to be_positive
  end
end
