class EnemImportJobsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_instructor!

  INEP_FILENAME_PATTERN = /\A\d{4}_(PV|GB)_[^_]+_D[12]_CD\d+\.pdf\z/i

  def index
    @jobs = current_tenant.enem_import_jobs.includes(:enem_exam, :user).order(created_at: :desc).limit(50)

    respond_to do |format|
      format.html
      format.json { render json: @jobs.as_json(only: %i[id status error_message enem_exam_id created_at updated_at]) }
    end
  end

  def create
    exam_pdf = params[:exam_pdf]
    answer_key_pdf = params[:answer_key_pdf]

    validation_error = validate_pdf_pair(exam_pdf:, answer_key_pdf:)
    if validation_error
      return respond_with_error(validation_error, status: :unprocessable_content)
    end

    import_job = current_tenant.enem_import_jobs.new(user: current_user)
    import_job.exam_pdf.attach(exam_pdf)
    import_job.answer_key_pdf.attach(answer_key_pdf)

    if import_job.save
      EnemImportWorker.perform_async(import_job.id)
      respond_to do |format|
        format.html { redirect_to enem_import_jobs_path, notice: "Import criado com sucesso. Processamento iniciado." }
        format.json { render json: { id: import_job.id, status: import_job.status }, status: :created }
      end
    else
      respond_with_error(import_job.errors.full_messages.join(", "), status: :unprocessable_content)
    end
  end

  private

  def validate_pdf_pair(exam_pdf:, answer_key_pdf:)
    return "Envie os dois arquivos: prova e gabarito." if exam_pdf.blank? || answer_key_pdf.blank?

    exam_filename = exam_pdf.original_filename.to_s
    answer_filename = answer_key_pdf.original_filename.to_s

    return "Nome do PDF da prova fora do padrão INEP." unless valid_inep_filename?(exam_filename, "PV")
    return "Nome do PDF do gabarito fora do padrão INEP." unless valid_inep_filename?(answer_filename, "GB")
    return "Cor do caderno diferente entre prova e gabarito." unless same_booklet_color?(exam_filename, answer_filename)

    nil
  end

  def valid_inep_filename?(filename, type)
    return false unless filename.match?(INEP_FILENAME_PATTERN)

    filename.include?("_#{type}_")
  end

  def same_booklet_color?(exam_filename, answer_filename)
    booklet_color(exam_filename) == booklet_color(answer_filename)
  end

  def booklet_color(filename)
    filename[/_CD\d+\.pdf\z/i]&.delete_suffix(".pdf")&.upcase
  end

  def respond_with_error(message, status:)
    respond_to do |format|
      format.html { redirect_to enem_import_jobs_path, alert: message }
      format.json { render json: { error: message }, status: status }
    end
  end
end
