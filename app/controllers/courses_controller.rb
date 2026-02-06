class CoursesController < ApplicationController
  before_action :set_course, only: [ :show, :edit, :update, :destroy ]

  def index
    # Apenas cursos do tenant atual serão retornados automaticamente
    @courses = Course.all
    respond_to do |format|
      format.html
      format.json { render json: @courses }
    end
  end

  def show; end

  def new
    @course = Course.new
  end

  def create
    # O tenant_id é automaticamente associado pelo acts_as_tenant
    @course = Course.new(course_params)

    if @course.save
      respond_to do |format|
        format.html { redirect_to @course, notice: "Curso #{@course.name} criado com sucesso." }
        format.json { render json: {
            course: @course,
            message: "Curso #{@course.name} criado com sucesso."
        }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    if @course.update(course_params)
      respond_to do |format|
        format.html { redirect_to @course, notice: "Curso #{@courser.name} atualizado com sucesso." }
        format.json { render json: {
            course: @course,
            message: "Curso #{@course.name} atualizado com sucesso."
        }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @course.destroy
      respond_to do |format|
        format.html { redirect_to courses_path, notice: "Curso #{@course.name} deletado com sucesso." }
        format.json { render json: {
            course: @course,
            message: "Curso #{@course.name} deletado com sucesso."
        }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to courses_path, alert: "Erro ao deletar curso #{@course.name}." }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
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
