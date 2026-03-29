class CoursesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :require_admin_or_instructor!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  def index
    # Apenas cursos do tenant atual serão retornados automaticamente
    @courses = Course.all
  end

  def show
    @sessions = @course.sessions.order(:position).includes(:lessons)
    @all_lessons = @sessions.flat_map(&:lessons)

    if user_signed_in?
      completions = LessonCompletion.where(user: current_user, lesson: @all_lessons)
      @completions = completions.index_by(&:lesson_id)
    else
      @completions = {}
    end

    @first_lesson = @all_lessons.first
  end

  def new
    @course = Course.new
  end

  def create
    # O tenant_id é automaticamente associado pelo acts_as_tenant
    @course = Course.new(course_params)

    if @course.save
      redirect_to @course, notice: "Curso criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to @course, notice: "Curso atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_path, notice: "Curso removido com sucesso."
  end

  private

  def set_course
    # Busca apenas cursos do tenant atual
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :description, :active)
  end
end
