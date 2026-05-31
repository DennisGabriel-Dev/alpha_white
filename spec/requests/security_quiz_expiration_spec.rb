# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Segurança — expiração de quiz no servidor", type: :request do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:course) { create(:course, tenant:) }
  let!(:session) { create(:session, course:, tenant:) }
  let!(:lesson) { create(:lesson, :with_video_url, session:, tenant:, quiz_time_limit_seconds: 600) }
  let!(:quiz) { create(:quiz, lesson:, tenant:) }
  let!(:question) do
    q = build(:question, quiz:, tenant:)
    q.question_options.build(text: "A", correct: true, position: 0)
    q.question_options.build(text: "B", correct: false, position: 1)
    q.save!
    q
  end
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }
  let(:correct_option) { question.question_options.find_by!(correct: true) }

  before do
    sign_in student
    LessonCompletion.create!(user: student, lesson:, video_watched: true)
  end

  it "bloqueia submit quando a tentativa já expirou (started_at no passado)" do
    attempt = create(
      :quiz_attempt,
      quiz:,
      user: student,
      tenant:,
      started_at: 20.minutes.ago,
      time_limit_seconds: 600,
      submitted_at: nil
    )

    expect do
      post submit_course_session_lesson_quiz_path(course, session, lesson),
           params: { answers: { question.id.to_s => correct_option.id.to_s } },
           headers: headers
    end.not_to change(StudentAnswer, :count)

    expect(response).to redirect_to(take_course_session_lesson_quiz_path(course, session, lesson))
    expect(flash[:alert]).to include("Tempo esgotado")

    attempt.reload
    expect(attempt.submitted_at).to be_present
    expect(attempt.submitted_at).to be_within(1.second).of(attempt.expires_at)
  end

  it "ainda permite submit dentro do limite" do
    create(
      :quiz_attempt,
      quiz:,
      user: student,
      tenant:,
      started_at: 5.minutes.ago,
      time_limit_seconds: 600,
      submitted_at: nil
    )

    post submit_course_session_lesson_quiz_path(course, session, lesson),
         params: { answers: { question.id.to_s => correct_option.id.to_s } },
         headers: headers

    expect(response).not_to redirect_to(take_course_session_lesson_quiz_path(course, session, lesson))
    expect(StudentAnswer.where(user: student, question:)).to exist
  end
end
