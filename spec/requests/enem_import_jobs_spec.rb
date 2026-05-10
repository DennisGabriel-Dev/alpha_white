require "rails_helper"

RSpec.describe "EnemImportJobs", type: :request do
  let(:tenant) { create(:tenant) }
  let(:admin) { create(:user, :tenant_admin, tenant:) }
  let(:instructor) { create(:user, :instructor, tenant:) }
  let(:student) { create(:user, :student, tenant:) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  def upload(filename)
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files", filename),
      "application/pdf"
    )
  end

  describe "POST /enem_import_jobs" do
    let(:valid_params) do
      {
        exam_pdf: upload("2023_PV_impresso_D1_CD1.pdf"),
        answer_key_pdf: upload("2023_GB_impresso_D1_CD1.pdf")
      }
    end

    context "sem autenticação" do
      it "redireciona para login" do
        post enem_import_jobs_path, params: valid_params, headers: headers
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "como estudante" do
      before { sign_in student }

      it "não cria job e redireciona para root" do
        expect {
          post enem_import_jobs_path, params: valid_params, headers: headers
        }.not_to change(EnemImportJob, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context "como admin" do
      before do
        sign_in admin
        allow(EnemImportWorker).to receive(:perform_async).and_return("jid-1")
      end

      it "cria job e enfileira worker" do
        expect {
          post enem_import_jobs_path, params: valid_params, headers: headers
        }.to change(EnemImportJob, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(EnemImportWorker).to have_received(:perform_async)
      end
    end

    context "como instrutor" do
      before do
        sign_in instructor
        allow(EnemImportWorker).to receive(:perform_async).and_return("jid-2")
      end

      it "também cria job" do
        post enem_import_jobs_path, params: valid_params, headers: headers
        expect(response).to have_http_status(:created)
      end
    end
  end
end
