class EnemExamsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_instructor!
  before_action :set_enem_exam, only: [:show, :edit, :update]

  def index
    @enem_exams = EnemExam.includes(:enem_questions).order(year: :desc, day: :asc, booklet_color: :asc)
  end

  def show
    @enem_questions = @enem_exam.enem_questions.order(:number_in_exam)
  end

  def edit
  end

  def update
    metadata = parse_json_or_nil(params.dig(:enem_exam, :metadata_json))
    return if performed?

    attrs = enem_exam_params.to_h
    attrs[:metadata] = metadata if metadata

    if @enem_exam.update(attrs)
      redirect_to enem_exam_path(@enem_exam), notice: "Prova ENEM atualizada com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_enem_exam
    @enem_exam = EnemExam.find(params[:id])
  end

  def enem_exam_params
    params.require(:enem_exam).permit(:year, :day, :booklet_color)
  end

  def parse_json_or_nil(raw_json)
    return nil if raw_json.blank?

    JSON.parse(raw_json)
  rescue JSON::ParserError
    redirect_back fallback_location: enem_exams_path, alert: "JSON de metadata inválido."
  end
end
