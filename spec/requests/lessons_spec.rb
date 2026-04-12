require "rails_helper"

RSpec.describe "Lessons", type: :request do
  let(:tenant)     { create(:tenant) }
  let(:admin)      { create(:user, :tenant_admin, tenant: tenant) }
  let(:student)    { create(:user, :student,      tenant: tenant) }
  let!(:course)    { create(:course,  tenant: tenant) }
  let!(:session)   { create(:session, course: course, tenant: tenant) }
  let!(:lesson)    { create(:lesson,  session: session, tenant: tenant) }

  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  describe "GET /courses/:course_id/sessions/:session_id/lessons/:id" do
    context "sem autenticação" do
      it "redireciona para login" do
        get course_session_lesson_path(course, session, lesson), headers: headers
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "autenticado como estudante" do
      before { sign_in student }

      it "retorna 200" do
        get course_session_lesson_path(course, session, lesson), headers: headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /courses/:course_id/sessions/:session_id/lessons/new" do
    context "sem autenticação" do
      it "redireciona para login" do
        get new_course_session_lesson_path(course, session), headers: headers
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "autenticado como estudante" do
      before { sign_in student }

      it "redireciona para root (sem permissão)" do
        get new_course_session_lesson_path(course, session), headers: headers
        expect(response).to redirect_to(root_path)
      end
    end

    context "autenticado como admin" do
      before { sign_in admin }

      it "retorna 200" do
        get new_course_session_lesson_path(course, session), headers: headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /courses/:course_id/sessions/:session_id/lessons" do
    let(:valid_params) { { lesson: { name: "Aula nova", position: 0 } } }

    context "sem autenticação" do
      it "não cria a aula" do
        expect {
          post course_session_lessons_path(course, session), params: valid_params, headers: headers
        }.not_to change(Lesson, :count)
      end
    end

    context "autenticado como estudante" do
      before { sign_in student }

      it "não cria a aula" do
        expect {
          post course_session_lessons_path(course, session), params: valid_params, headers: headers
        }.not_to change(Lesson, :count)
      end
    end

    context "autenticado como admin" do
      before { sign_in admin }

      it "cria a aula" do
        expect {
          post course_session_lessons_path(course, session), params: valid_params, headers: headers
        }.to change(Lesson, :count).by(1)
      end
    end
  end
end
