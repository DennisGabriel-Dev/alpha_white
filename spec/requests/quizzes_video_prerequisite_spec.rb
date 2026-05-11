require "rails_helper"

RSpec.describe "Quiz video prerequisite", type: :request do
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

  before { sign_in student }

  describe "GET /courses/.../quiz/take" do
    it "bloqueia aluno até marcar o vídeo como assistido" do
      get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers

      expect(response).to redirect_to(course_session_lesson_path(course, session, lesson, tab: "quiz"))
      expect(flash[:alert]).to include("Assista à aula")
    end

    it "libera após video_watched" do
      patch course_session_lesson_lesson_completion_path(course, session, lesson),
            params: { lesson_completion: { video_watched: true } },
            headers: headers

      get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /courses/.../quiz/submit" do
    it "bloqueia envio sem pré-requisito do vídeo" do
      post submit_course_session_lesson_quiz_path(course, session, lesson),
           params: { answers: { question.id.to_s => question.question_options.first.id } },
           headers: headers

      expect(response).to redirect_to(course_session_lesson_path(course, session, lesson, tab: "quiz"))
    end
  end

  describe "aula sem vídeo" do
    let!(:lesson) { create(:lesson, session:, tenant:, video_url: nil) }

    it "permite iniciar a prova sem marcação de vídeo" do
      get take_course_session_lesson_quiz_path(course, session, lesson), headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
