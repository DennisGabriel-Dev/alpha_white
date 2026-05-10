class EnemExamQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_instructor!
  before_action :set_enem_exam
  before_action :set_enem_question

  def edit
  end

  def update
    alternatives = parse_json_array(params.dig(:enem_question, :alternatives_json))
    return if performed?

    attrs = enem_question_params.to_h
    attrs[:alternatives] = alternatives if alternatives

    if @enem_question.update(attrs)
      redirect_to enem_exam_path(@enem_exam), notice: "Questão ENEM atualizada com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_enem_exam
    @enem_exam = EnemExam.find(params[:enem_exam_id])
  end

  def set_enem_question
    @enem_question = @enem_exam.enem_questions.find(params[:id])
  end

  def enem_question_params
    params.require(:enem_question).permit(:number_in_exam, :area, :skill, :statement, :correct_letter)
  end

  def parse_json_array(raw_json)
    return nil if raw_json.blank?

    parsed = JSON.parse(raw_json)
    return parsed if parsed.is_a?(Array)

    redirect_back fallback_location: enem_exam_path(@enem_exam), alert: "Alternativas deve ser um JSON array."
  rescue JSON::ParserError
    redirect_back fallback_location: enem_exam_path(@enem_exam), alert: "JSON de alternativas inválido."
  end
end
