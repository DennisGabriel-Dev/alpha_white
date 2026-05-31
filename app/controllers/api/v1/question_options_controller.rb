# frozen_string_literal: true

class Api::V1::QuestionOptionsController < Api::V1::BaseController
  before_action :set_question
  before_action :set_question_option, only: [:show, :update, :destroy]
  before_action :authorize_admin_or_instructor!, only: [:create, :update, :destroy]

  def index
    @options = @question.question_options
    render json: { question_options: serialize_question_options(@options), total: @options.count }
  end

  def show
    render json: { question_option: serialize_question_option(@question_option) }
  end

  def create
    @option = @question.question_options.build(question_option_params)
    if @option.save
      render json: { question_option: @option, message: "Alternative created successfully." }, status: :created
    else
      render json: { errors: @option.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @question_option.update(question_option_params)
      render json: { question_option: @question_option, message: "Alternative updated successfully." }
    else
      render json: { errors: @question_option.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @question_option.destroy
    render json: { message: "Alternative removed successfully." }
  end

  private

  def set_question
    @question = Question.joins(quiz: { lesson: { session: :course } })
                        .where(courses: { tenant_id: ActsAsTenant.current_tenant.id })
                        .find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Question not found" }, status: :not_found
  end

  def set_question_option
    @question_option = @question.question_options.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Alternative not found" }, status: :not_found
  end

  def question_option_params
    params.require(:question_option).permit(:text, :correct, :position)
  end
end