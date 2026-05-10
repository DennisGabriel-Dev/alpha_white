require "rails_helper"

RSpec.describe EnemImportWorker do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, :tenant_admin, tenant:) }

  it "atualiza job para done quando extração e persistência funcionam" do
    job = build(:enem_import_job, tenant:, user:)
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
    job.save!

    payload = { "exam" => { "year" => 2023, "day" => "D1", "booklet_color" => "CD1", "metadata" => {} }, "questions" => [] }
    exam = create(:enem_exam, year: 2023, day: "D1", booklet_color: "CD1")

    allow_any_instance_of(Enem::ExtractorClient).to receive(:extract).and_return(payload)
    allow_any_instance_of(Enem::PersistFromPayload).to receive(:call).and_return(exam)

    described_class.new.perform(job.id)

    expect(job.reload).to be_done
    expect(job.enem_exam_id).to eq(exam.id)
  end
end
