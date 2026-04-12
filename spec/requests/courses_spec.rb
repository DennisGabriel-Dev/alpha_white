require "rails_helper"

RSpec.describe "Courses", type: :request do
  let(:tenant)       { create(:tenant) }
  let(:admin)        { create(:user, :tenant_admin, tenant: tenant) }
  let(:instructor)   { create(:user, :instructor,   tenant: tenant) }
  let(:student)      { create(:user, :student,      tenant: tenant) }
  let!(:course)      { create(:course, tenant: tenant) }

  # Simula request com o subdomain do tenant
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  # ── Leitura (público) ────────────────────────────────────────────────────────

  describe "GET /courses" do
    it "permite acesso sem autenticação" do
      get courses_path, headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /courses/:id" do
    it "permite acesso sem autenticação" do
      get course_path(course), headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  # ── Criação ──────────────────────────────────────────────────────────────────

  describe "GET /courses/new" do
    context "sem autenticação" do
      it "redireciona para login" do
        get new_course_path, headers: headers
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "autenticado como estudante" do
      before { sign_in student }

      it "redireciona para root com alerta" do
        get new_course_path, headers: headers
        expect(response).to redirect_to(root_path)
      end
    end

    context "autenticado como admin" do
      before { sign_in admin }

      it "retorna 200" do
        get new_course_path, headers: headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "autenticado como instrutor" do
      before { sign_in instructor }

      it "retorna 200" do
        get new_course_path, headers: headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /courses" do
    let(:valid_params) { { course: { name: "Novo Curso", description: "Desc", active: true } } }

    context "sem autenticação" do
      it "redireciona para login" do
        post courses_path, params: valid_params, headers: headers
        expect(response).to redirect_to(new_user_session_path)
      end

      it "não cria o curso" do
        expect {
          post courses_path, params: valid_params, headers: headers
        }.not_to change(Course, :count)
      end
    end

    context "autenticado como estudante" do
      before { sign_in student }

      it "não cria o curso e redireciona" do
        expect {
          post courses_path, params: valid_params, headers: headers
        }.not_to change(Course, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context "autenticado como admin" do
      before { sign_in admin }

      it "cria o curso e redireciona" do
        expect {
          post courses_path, params: valid_params, headers: headers
        }.to change(Course, :count).by(1)
        expect(response).to redirect_to(course_path(Course.last))
      end

      it "não cria com parâmetros inválidos" do
        expect {
          post courses_path, params: { course: { name: "" } }, headers: headers
        }.not_to change(Course, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # ── Edição ───────────────────────────────────────────────────────────────────

  describe "GET /courses/:id/edit" do
    context "sem autenticação" do
      it "redireciona para login" do
        get edit_course_path(course), headers: headers
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "autenticado como estudante" do
      before { sign_in student }

      it "redireciona para root" do
        get edit_course_path(course), headers: headers
        expect(response).to redirect_to(root_path)
      end
    end

    context "autenticado como admin" do
      before { sign_in admin }

      it "retorna 200" do
        get edit_course_path(course), headers: headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "PATCH /courses/:id" do
    context "sem autenticação" do
      it "redireciona para login" do
        patch course_path(course), params: { course: { name: "Novo nome" } }, headers: headers
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "autenticado como admin" do
      before { sign_in admin }

      it "atualiza o curso" do
        patch course_path(course), params: { course: { name: "Nome atualizado" } }, headers: headers
        expect(course.reload.name).to eq("Nome atualizado")
        expect(response).to redirect_to(course_path(course))
      end
    end
  end

  # ── Exclusão ─────────────────────────────────────────────────────────────────

  describe "DELETE /courses/:id" do
    context "sem autenticação" do
      it "não exclui o curso" do
        expect {
          delete course_path(course), headers: headers
        }.not_to change(Course, :count)
      end
    end

    context "autenticado como estudante" do
      before { sign_in student }

      it "não exclui o curso" do
        expect {
          delete course_path(course), headers: headers
        }.not_to change(Course, :count)
      end
    end

    context "autenticado como admin" do
      before { sign_in admin }

      it "exclui o curso" do
        expect {
          delete course_path(course), headers: headers
        }.to change(Course, :count).by(-1)
        expect(response).to redirect_to(courses_path)
      end
    end
  end
end
