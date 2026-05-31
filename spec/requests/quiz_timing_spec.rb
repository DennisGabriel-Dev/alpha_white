# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Quiz timing", type: :request do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:course) { create(:course, tenant:) }
  let!(:session) { create(:session, course:, tenant:) }
  let!(:lesson) { create(:lesson, :with_video_url, session:, tenant:, quiz_time_limit_seconds: 600) }
  let!(:quiz) { create(:quiz, lesson:, tenant:) }
  let!(:question) do
    create(:question, quiz:, tenant:,
                      question_options_attributes: [
                        { text: "A", correct: true, position: 0 },
                        { text: "B", correct: false, position: 1 }
                      ])
  end

  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }
  let(:correct_option) { question.question_options.find_by!(correct: true) }

  before do
    sign_in student
    LessonCompletion.create!(user: student, lesson:, video_watched: true)
  end

  describe "GET take" do
    it "cria tentativa em andamento com limite da aula" do
      expect do
        get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers
      end.to change { QuizAttempt.in_progress.where(user: student, quiz: quiz).count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tempo restante")
      attempt = QuizAttempt.in_progress.find_by!(user: student, quiz: quiz)
      expect(attempt.time_limit_seconds).to eq(600)
    end

    it "reutiliza tentativa em andamento ao reabrir" do
      get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers
      first_id = QuizAttempt.in_progress.find_by!(user: student, quiz: quiz).id

      get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers
      expect(QuizAttempt.in_progress.where(user: student, quiz: quiz).count).to eq(1)
      expect(QuizAttempt.in_progress.find_by!(user: student, quiz: quiz).id).to eq(first_id)
    end
  end

  describe "POST submit" do
    it "finaliza tentativa e permite nova após envio" do
      get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers

      post submit_course_session_lesson_quiz_path(course, session, lesson),
           params: { answers: { question.id.to_s => correct_option.id.to_s } },
           headers: headers

      expect(QuizAttempt.submitted.where(user: student, quiz: quiz).count).to eq(1)

      get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers
      expect(QuizAttempt.in_progress.where(user: student, quiz: quiz).count).to eq(1)
      expect(QuizAttempt.where(user: student, quiz: quiz).count).to eq(2)
    end

    it "registra tempo por questão quando enviado" do
      get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers

      post submit_course_session_lesson_quiz_path(course, session, lesson),
           params: {
             answers: { question.id.to_s => correct_option.id.to_s },
             time_spent: { question.id.to_s => "42" }
           },
           headers: headers

      answer = StudentAnswer.joins(:quiz_attempt).find_by(user: student, question: question)
      expect(answer.time_spent_seconds).to eq(42)
      expect(answer.quiz_attempt.submitted_at).to be_present
    end
  end
end
