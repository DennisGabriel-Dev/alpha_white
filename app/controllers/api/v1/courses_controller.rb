# API V1 - Courses Controller (apenas JSON)
class Api::V1::CoursesController < Api::V1::BaseController
  before_action :set_course, only: [ :show, :update, :destroy ]
  before_action :authorize_admin_or_instructor!, only: [ :create, :update, :destroy ]

  # GET /api/v1/courses
  def index
    @courses = Course.all
    render json: {
      courses: @courses,
      total: @courses.count
    }
  end

  # GET /api/v1/courses/:id
  def show
    render json: {
      course: @course
    }
  end

  # POST /api/v1/courses
  def create
    @course = Course.new(course_params)

    if @course.save
      render json: {
        course: @course,
        message: "Curso criado com sucesso."
      }, status: :created
    else
      render json: {
        errors: @course.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/courses/:id
  def update
    if @course.update(course_params)
      render json: {
        course: @course,
        message: "Curso atualizado com sucesso."
      }
    else
      render json: {
        errors: @course.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/courses/:id
  def destroy
    if @course.destroy
      render json: {
        message: "Curso deletado com sucesso."
      }
    else
      render json: {
        errors: [ "Erro ao deletar curso" ]
      }, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "Curso não encontrado"
    }, status: :not_found
  end

  def course_params
    params.require(:course).permit(:name, :description, :active)
  end
end
