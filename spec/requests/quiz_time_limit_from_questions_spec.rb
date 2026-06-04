# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tempo da prova na lista de questões", type: :request do
  let(:tenant) { create(:tenant) }
  let(:instructor) { create(:user, :instructor, tenant:) }
  let(:course) { create(:course, tenant:) }
  let(:session) { create(:session, course:, tenant:) }
  let(:lesson) { create(:lesson, session:, tenant:, quiz_time_limit_seconds: 600) }
  let!(:quiz) { create(:quiz, lesson:, tenant:) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  it "atualiza o tempo limite e redireciona de volta para questões" do
    sign_in instructor
    patch course_session_lesson_path(course, session, lesson),
          params: { lesson: { quiz_time_limit_minutes: 15 }, return_to: "quiz_questions" },
          headers: headers

    expect(response).to redirect_to(course_session_lesson_quiz_questions_path(course, session, lesson))
    expect(flash[:notice]).to include("Tempo da prova")
    expect(lesson.reload.quiz_time_limit_seconds).to eq(900)
  end
end
