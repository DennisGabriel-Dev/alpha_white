# frozen_string_literal: true

class Api::V1::FeedbacksController < Api::V1::BaseController
  before_action :set_lesson

  def index
    @feedbacks = @lesson.feedbacks
    render json: { feedbacks: @feedbacks, total: @feedbacks.count }
  end

  def create
    @feedback = @lesson.feedbacks.build(feedback_params.merge(user: current_user))
    if @feedback.save
      render json: { feedback: @feedback, message: "Feedback enviado com sucesso." }, status: :created
    else
      render json: { errors: @feedback.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_lesson
    @lesson = Lesson.joins(session: :course).where(courses: { tenant_id: ActsAsTenant.current_tenant.id }).find(params[:lesson_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Aula não encontrada" }, status: :not_found
  end

  def feedback_params
    params.require(:feedback).permit(:rating, :description)
  end
end
