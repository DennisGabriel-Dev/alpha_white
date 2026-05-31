# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Segurança — gabarito na UI de questões", type: :request do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let(:instructor) { create(:user, :instructor, tenant:) }
  let(:course) { create(:course, tenant:) }
  let(:session) { create(:session, course:, tenant:) }
  let(:lesson) { create(:lesson, session:, tenant:) }
  let!(:quiz) { create(:quiz, lesson:, tenant:) }
  let!(:question) do
    q = build(:question, quiz:, tenant:)
    q.question_options.build(text: "Certa", correct: true, position: 0)
    q.question_options.build(text: "Errada", correct: false, position: 1)
    q.save!
    q
  end
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  it "bloqueia aluno na lista de questões (gabarito)" do
    sign_in student
    get course_session_lesson_quiz_questions_path(course, session, lesson), headers: headers

    expect(response).to redirect_to(root_path)
  end

  it "permite instrutor ver gabarito" do
    sign_in instructor
    get course_session_lesson_quiz_questions_path(course, session, lesson), headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("(correta)")
  end
end
