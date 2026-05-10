require "rails_helper"

RSpec.describe EnemImportJob, type: :model do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, :tenant_admin, tenant:) }

  before { set_tenant(tenant) }

  describe "associações" do
    it { should belong_to(:tenant).optional }
    it { should belong_to(:user) }
    it { should belong_to(:enem_exam).optional }
  end

  describe "enum status" do
    it { should define_enum_for(:status).with_values(pending: 0, processing: 1, done: 2, failed: 3) }
  end

  describe "validações de anexos" do
    it "exige prova e gabarito" do
      job = build(:enem_import_job, tenant:, user:)
      expect(job).not_to be_valid
      expect(job.errors[:exam_pdf]).to be_present
      expect(job.errors[:answer_key_pdf]).to be_present
    end
  end

  describe "herança de tenant do usuário" do
    it "preenche tenant automaticamente" do
      job = described_class.new(user:)
      job.exam_pdf.attach(
        io: StringIO.new("fake-pdf"),
        filename: "2023_PV_impresso_D1_CD1.pdf",
        content_type: "application/pdf"
      )
      job.answer_key_pdf.attach(
        io: StringIO.new("fake-pdf"),
        filename: "2023_GB_impresso_D1_CD1.pdf",
        content_type: "application/pdf"
      )

      expect(job).to be_valid
      expect(job.tenant_id).to eq(tenant.id)
    end
  end
end
