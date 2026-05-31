# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Segurança — API RBAC e gabarito", type: :request do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let(:instructor) { create(:user, :instructor, tenant:) }
  let(:headers) do
    {
      "HOST" => "#{tenant.subdomain}.lvh.me",
      "Authorization" => "Bearer #{JwtService.encode(user: auth_user)}"
    }
  end
  let(:auth_user) { student }
  let!(:course) { create(:course, tenant:) }

  describe "POST /api/v1/courses" do
    it "bloqueia aluno" do
      post "/api/v1/courses",
           params: { course: { name: "Hack", description: "x", active: true } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:forbidden)
    end

    context "como instrutor" do
      let(:auth_user) { instructor }

      it "permite criar curso" do
        post "/api/v1/courses",
             params: { course: { name: "Novo curso", description: "ok", active: true } },
             headers: headers,
             as: :json

        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/v1/.../question_options" do
    let(:session) { create(:session, course:, tenant:) }
    let(:lesson) { create(:lesson, session:, tenant:) }
    let!(:quiz) { create(:quiz, lesson:, tenant:) }
    let!(:question) do
      q = build(:question, quiz:, tenant:)
      q.question_options.build(text: "A", correct: true, position: 0)
      q.question_options.build(text: "B", correct: false, position: 1)
      q.save!
      q
    end

    it "não expõe correct para aluno" do
      get "/api/v1/courses/#{course.id}/sessions/#{session.id}/lessons/#{lesson.id}/quizzes/#{quiz.id}/questions/#{question.id}/question_options",
          headers: headers,
          as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["question_options"].first).not_to have_key("correct")
    end

    context "como instrutor" do
      let(:auth_user) { instructor }

      it "expõe correct para staff" do
        get "/api/v1/courses/#{course.id}/sessions/#{session.id}/lessons/#{lesson.id}/quizzes/#{quiz.id}/questions/#{question.id}/question_options",
            headers: headers,
            as: :json

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["question_options"].map { |o| o["correct"] }).to contain_exactly(true, false)
      end
    end
  end
end
