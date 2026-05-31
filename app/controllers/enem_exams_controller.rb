class EnemExamsController < ApplicationController
  include RequiresTenantFeature

  before_action :authenticate_user!
  before_action :require_admin_or_instructor!
  before_action -> { require_tenant_feature!(:enem_library) }
  before_action :set_enem_exam, only: [:show, :edit, :update]

  def index
    scope = EnemExam.includes(:enem_questions)
    if params[:year].present?
      y = params[:year].to_i
      scope = scope.where(year: y) if y.between?(1991, 2099)
    end
    if params[:day].present? && EnemExam::DAY_VALUES.include?(params[:day])
      scope = scope.where(day: params[:day])
    end
    if params[:booklet_color].present?
      scope = scope.where("LOWER(booklet_color) = ?", params[:booklet_color].to_s.strip.downcase)
    end

    @enem_exams = scope.order(year: :desc, day: :asc, booklet_color: :asc)
    @filter_years = EnemExam.distinct.order(year: :desc).pluck(:year)
    @filter_colors = EnemExam.distinct.pluck(:booklet_color).sort_by { |c| c.to_s.downcase }
  end

  def show
    @enem_questions = @enem_exam.enem_questions.order(:number_in_exam)
    if params[:number].present?
      num = params[:number].to_s.strip.to_i
      @enem_questions = @enem_questions.where(number_in_exam: num) if num.positive?
    end
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
