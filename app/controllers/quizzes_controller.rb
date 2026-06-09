# frozen_string_literal: true

class QuizzesController < ApplicationController
  include GamificationFlash

  before_action :authenticate_user!
  before_action :require_admin_or_instructor!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_course
  before_action :set_session
  before_action :set_lesson
  before_action :ensure_video_prerequisite_for_students!, only: [:take, :submit]
  before_action :set_quiz, only: [:edit, :update, :destroy, :take, :submit, :review]

  def take
    @quiz = @lesson.quiz
    unless @quiz
      redirect_to course_session_lesson_path(@course, @session, @lesson), alert: "Prova não encontrada"
      return
    end

    return unless prepare_student_quiz_attempt!

    @expires_at = @quiz_attempt&.expires_at
  end

  def review
    @quiz_review = true
    unless @quiz.user_has_student_answers?(current_user)
      redirect_to course_session_lesson_path(@course, @session, @lesson, tab: "quiz"),
                  alert: "Não há respostas registradas para conferir."
      return
    end

    @review_attempt = @quiz.latest_submitted_attempt_for(current_user)
    assign_quiz_review_summary(@review_attempt)
    render :take
  end

  def submit
    @quiz = @lesson.quiz
    unless @quiz
      redirect_to course_session_lesson_path(@course, @session, @lesson), alert: "Prova não encontrada"
      return
    end

    @quiz_attempt = QuizAttempt.in_progress.find_by(quiz: @quiz, user: current_user)
    unless @quiz_attempt
      redirect_to take_course_session_lesson_quiz_path(@course, @session, @lesson),
                  alert: "Nenhuma tentativa em andamento. Inicie a prova novamente."
      return
    end

    if @quiz_attempt.expired?
      answered = persist_answers_for_attempt!(@quiz_attempt)
      @quiz_attempt.submit!(at: @quiz_attempt.expires_at)
      redirect_to take_course_session_lesson_quiz_path(@course, @session, @lesson),
                  alert: "Tempo esgotado. Suas respostas parciais foram registradas. Você pode iniciar uma nova tentativa."
      return
    end

    answered = persist_answers_for_attempt!(@quiz_attempt)

    @quiz_attempt.submit!
    completion = update_lesson_completion_after_submit!

    gamification = nil
    gamification = run_gamification!(quiz: @quiz, lesson_just_completed: completion.completed?) if current_user.student?

    lesson_path = course_session_lesson_path(@course, @session, @lesson, tab: "quiz")
    base_notice = if completion.quiz_completed?
                    "Prova concluída! Confira o desempenho abaixo."
                  else
                    "Respostas enviadas (#{answered} nesta submissão). Responda todas as questões para concluir a prova."
                  end
    notice = notice_with_gamification(base_notice, gamification)

    if completion.quiz_completed?
      redirect_to review_course_session_lesson_quiz_path(@course, @session, @lesson), notice: notice
    else
      redirect_to lesson_path, notice: notice
    end
  end

  def new
    redirect_to edit_course_session_lesson_quiz_path(@course, @session, @lesson) if @lesson.quiz.present?
    @quiz = @lesson.build_quiz
  end

  def create
    @quiz = @lesson.build_quiz(quiz_params)
    if @quiz.save
      redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                  notice: "Prova criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @quiz.update(quiz_params)
      redirect_to course_session_lesson_quiz_questions_path(@course, @session, @lesson),
                  notice: "Prova atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quiz.destroy
    redirect_to course_session_lesson_path(@course, @session, @lesson),
                notice: "Prova removida com sucesso."
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
    redirect_to course_session_lesson_path(@course, @session, @lesson), alert: "Prova não encontrada" unless @quiz
  end

  def quiz_params
    params.require(:quiz).permit(:title)
  end

  def ensure_video_prerequisite_for_students!
    return unless student?

    return if @lesson.video_prerequisite_met_for?(current_user)

    redirect_to course_session_lesson_path(@course, @session, @lesson, tab: "quiz"),
                alert: "Assista à aula ou marque como assistido antes de iniciar a prova."
  end

  def prepare_student_quiz_attempt!
    return true unless current_user.student?

    Quizzes::FinalizeExpiredAttempts.new(quiz: @quiz, user: current_user).call
    @quiz_attempt = Quizzes::EnsureAttempt.new(quiz: @quiz, user: current_user).call
    true
  end

  def persist_answers_for_attempt!(attempt)
    answered = 0
    params[:answers]&.each do |question_id, question_option_id|
      next if question_option_id.blank?

      question = @quiz.questions.find_by(id: question_id)
      option = question&.question_options&.find_by(id: question_option_id)
      next unless question && option

      time_spent = params.dig(:time_spent, question_id).to_i
      answer = attempt.student_answers.find_or_initialize_by(question: question)
      answer.user = current_user
      if answer.update(
        question_option_id: option.id,
        time_spent_seconds: time_spent.positive? ? time_spent : nil
      )
        answered += 1
      end
    end
    answered
  end

  def update_lesson_completion_after_submit!
    completion = @lesson.lesson_completions.find_or_initialize_by(user: current_user)
    question_ids = @quiz.questions.ids
    if question_ids.any?
      answered_for_quiz = @quiz_attempt.student_answers.where(question_id: question_ids).distinct.count(:question_id)
      completion.quiz_completed = true if answered_for_quiz >= question_ids.size
    end
    completion.save!
    completion
  end

  def assign_quiz_review_summary(attempt)
    questions = @quiz.questions.includes(:question_options, student_answers: :question_option)
    attempt_answers = attempt.student_answers.index_by(&:question_id)
    @review_correct = questions.count do |q|
      ans = attempt_answers[q.id]
      ans&.question_option&.correct?
    end
    @review_total = questions.size
    @review_attempt_number = attempt.attempt_number
    @review_attempt_count = @quiz.submitted_attempt_count_for(current_user)
  end
end
