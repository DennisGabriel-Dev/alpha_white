require "rails_helper"

RSpec.describe "Quiz review", type: :request do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:course) { create(:course, tenant:) }
  let!(:session) { create(:session, course:, tenant:) }
  let!(:lesson) { create(:lesson, :with_video_url, session:, tenant:) }
  let!(:quiz) { create(:quiz, lesson:, tenant:) }
  let!(:question) do
    create(:question, quiz:, tenant:,
                      question_options_attributes: [
                        { text: "A", correct: true, position: 0 },
                        { text: "B", correct: false, position: 1 }
                      ])
  end

  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }
  let(:wrong_option) { question.question_options.find_by!(correct: false) }

  before { sign_in student }

  describe "GET /courses/.../quiz/review" do
    it "redireciona quando não há respostas salvas" do
      get review_course_session_lesson_quiz_path(course, session, lesson), headers: headers

      expect(response).to redirect_to(course_session_lesson_path(course, session, lesson, tab: "quiz"))
      expect(flash[:alert]).to include("Não há respostas")
    end

    it "mostra a conferência quando há respostas" do
      StudentAnswer.create!(user: student, question:, question_option: wrong_option)

      get review_course_session_lesson_quiz_path(course, session, lesson), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Conferência")
      expect(response.body).to include("Gabarito")
    end

    it "não exige vídeo assistido (diferente de take/submit)" do
      StudentAnswer.create!(user: student, question:, question_option: wrong_option)

      get review_course_session_lesson_quiz_path(course, session, lesson), headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
