# frozen_string_literal: true

class Api::V1::LessonCompletionsController < Api::V1::BaseController
  before_action :set_lesson

  def show
    @completion = @lesson.lesson_completions.find_or_initialize_by(user: current_user)
    render json: {
      lesson_completion: @completion,
      completed: completion_completed?(@completion)
    }
  end

  def create
    @completion = @lesson.lesson_completions.find_or_initialize_by(user: current_user)
    if @completion.update(lesson_completion_params)
      render json: {
        lesson_completion: @completion,
        completed: completion_completed?(@completion),
        message: "Progresso registrado."
      }, status: @completion.previously_new_record? ? :created : :ok
    else
      render json: { errors: @completion.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    @completion = @lesson.lesson_completions.find_or_initialize_by(user: current_user)
    if @completion.update(lesson_completion_params)
      render json: {
        lesson_completion: @completion,
        completed: completion_completed?(@completion),
        message: "Progresso atualizado."
      }
    else
      render json: { errors: @completion.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_lesson
    @lesson = Lesson.joins(session: :course).where(courses: { tenant_id: ActsAsTenant.current_tenant.id }).find(params[:lesson_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Aula não encontrada" }, status: :not_found
  end

  def lesson_completion_params
    params.require(:lesson_completion).permit(:quiz_completed, :video_watched)
  end

  def completion_completed?(completion)
    completion.persisted? && (
      (completion.lesson.quiz.blank? || completion.quiz_completed?) &&
      ((!completion.lesson.video.attached? && completion.lesson.video_url.blank?) || completion.video_watched?)
    )
  end
end