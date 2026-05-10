class EnemImportWorker
  include Sidekiq::Worker

  def perform(import_job_id)
    import_job = EnemImportJob.find(import_job_id)
    import_job.mark_processing!

    payload = Enem::ExtractorClient.new.extract(
      exam_pdf_attachment: import_job.exam_pdf,
      answer_key_pdf_attachment: import_job.answer_key_pdf
    )

    exam = Enem::PersistFromPayload.new.call(payload:)
    import_job.mark_done!(exam:)
  rescue StandardError => e
    import_job&.mark_failed!(e.message)
    raise
  end
end
