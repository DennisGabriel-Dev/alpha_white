class CoursesController < ApplicationController
  include RequiresTenantFeature

  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :relatorio]
  before_action :require_admin_or_instructor!, only: [:new, :create, :edit, :update, :destroy, :relatorio]
  before_action -> { require_tenant_feature!(:csv_export) }, only: [:relatorio]
  before_action :set_course, only: [:show, :edit, :update, :destroy, :relatorio]

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
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to @course, notice: "Curso atualizado com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_path, notice: "Curso removido com sucesso."
  end

  def relatorio
    period = Reports::PeriodFilter.parse(params[:from], params[:to])
    csv = Reports::CourseCsvExport.new(
      course: @course,
      tenant: ActsAsTenant.current_tenant,
      from: period.from,
      to: period.to
    ).call

    filename = "curso-#{@course.id}-#{Date.current.iso8601}.csv"
    send_data csv, filename: filename, type: "text/csv; charset=utf-8", disposition: "attachment"
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
