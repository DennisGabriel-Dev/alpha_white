class QuizEnemImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_instructor!
  before_action :set_course
  before_action :set_session
  before_action :set_lesson
  before_action :set_quiz

  PER_PAGE = 25

  def new
    @ransack_params = permitted_q_params
    @q = EnemQuestion.ransack(@ransack_params)
    base = @q.result(distinct: true).includes(:enem_exam)
    @page = [ params[:page].to_i, 1 ].max
    @per_page = PER_PAGE
    @total_count = base.count(:id)
    @enem_questions = base.offset((@page - 1) * @per_page).limit(@per_page)
    @existing_enem_ids = @quiz.questions.where.not(enem_question_id: nil).pluck(:enem_question_id).to_set
    @year_options = EnemExam.distinct.order(year: :desc).pluck(:year)
    @color_options = EnemExam.distinct.pluck(:booklet_color).sort_by { |c| c.to_s.downcase }
  end

  def create
    ids = Array(params[:enem_question_ids]).compact_blank
    if ids.empty?
      redirect_to new_course_session_lesson_quiz_enem_import_path(@course, @session, @lesson),
                  alert: "Selecione ao menos uma questão da biblioteca."
      return
    end

    result = Quizzes::ImportFromEnemLibrary.new(quiz: @quiz, enem_question_ids: ids).call

    parts = []
    parts << "#{result.imported_count} questão(ões) adicionada(s) à prova." if result.imported_count.positive?
    parts << "#{result.skipped_duplicate_count} ignorada(s) (já estavam nesta prova)." if result.skipped_duplicate_count.positive?
    parts << "#{result.skipped_invalid_count} não importada(s) (dados incompletos)." if result.skipped_invalid_count.positive?

    flash[:notice] = parts.join(" ") if parts.any?
    if result.error_messages.any?
      flash[:alert] = result.error_messages.first(5).join(" ")
      flash[:alert] += " …" if result.error_messages.size > 5
    end

    redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson)
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_session
    @session = @course.sessions.find(params[:session_id])
  end

  def set_lesson
    @lesson = @session.lessons.find(params[:lesson_id])
  end

  def set_quiz
    @quiz = @lesson.quiz
    redirect_to course_session_lesson_path(@course, @session, @lesson), alert: "Prova não encontrada." unless @quiz
  end

  def permitted_q_params
    q = params[:q]
    return {} if q.blank?

    h = q.permit(
      :statement_cont,
      :area_eq,
      :number_in_exam_eq,
      :skill_cont,
      :enem_exam_year_eq,
      :enem_exam_day_eq,
      :enem_exam_booklet_color_eq
    ).to_h
    h.transform_values { |v| v.is_a?(String) ? v.strip.presence : v }.compact
  end
end
