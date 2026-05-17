require "rails_helper"

RSpec.describe Reports::StudentPerformance, type: :model do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:course) { create(:course, tenant:) }
  let!(:session) { create(:session, course:, tenant:) }
  let!(:lesson) { create(:lesson, session:, tenant:, video_url: nil) }

  it "calcula progresso por curso (aulas concluídas / total)" do
    LessonCompletion.create!(user: student, lesson:, quiz_completed: true, video_watched: true)

    result = ActsAsTenant.with_tenant(tenant) do
      Reports::StudentPerformance.new(user: student, tenant: tenant).call
    end

    row = result.course_rows.find { |r| r.course.id == course.id }
    expect(row).to be_present
    expect(row.completed).to eq(1)
    expect(row.total).to eq(1)
    expect(row.percent).to eq(100.0)
  end

  it "agrega acertos por área ENEM" do
    quiz = create(:quiz, lesson:, tenant:)
    eq = create(:enem_question, area: "MT")
    q = build(:question, quiz:, tenant:, enem_question: eq)
    q.question_options.build(text: "Certa", correct: true, position: 0)
    q.question_options.build(text: "Errada", correct: false, position: 1)
    q.save!

    opt_ok = q.question_options.find_by!(correct: true)
    StudentAnswer.create!(user: student, question: q, question_option: opt_ok)

    result = ActsAsTenant.with_tenant(tenant) do
      Reports::StudentPerformance.new(user: student, tenant: tenant).call
    end

    mt = result.enem_rows.find { |r| r.area == "MT" }
    expect(mt.total).to eq(1)
    expect(mt.correct).to eq(1)
    expect(mt.percent).to eq(100.0)
  end
end
