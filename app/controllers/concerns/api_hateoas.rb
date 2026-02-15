# frozen_string_literal: true

# Adiciona links HATEOAS às respostas da API.
# O frontend usa _links para saber quais ações o usuário pode realizar (ex: sidebar).
module ApiHateoas
  extend ActiveSupport::Concern

  private

  def admin_or_instructor?
    current_user&.super_admin? || current_user&.tenant_admin? || current_user&.instructor?
  end

  def hateoas_course_links(course)
    links = {}
    links[:self] = api_v1_course_path(course)
    links[:sessions] = api_v1_course_sessions_path(course)
    links[:create_session] = api_v1_course_sessions_path(course) if admin_or_instructor?
    links
  end

  def hateoas_session_links(course, session)
    links = {}
    links[:self] = api_v1_course_session_path(course, session)
    links[:course] = api_v1_course_path(course)
    links[:lessons] = api_v1_course_session_lessons_path(course, session)
    links[:create_lesson] = api_v1_course_session_lessons_path(course, session) if admin_or_instructor?
    links
  end

  def hateoas_lesson_links(course, session, lesson)
    links = {}
    links[:self] = api_v1_course_session_lesson_path(course, session, lesson)
    links[:session] = api_v1_course_session_path(course, session)
    links[:feedbacks] = api_v1_course_session_lesson_feedbacks_path(course, session, lesson)
    links[:create_feedback] = api_v1_course_session_lesson_feedbacks_path(course, session, lesson)
    links[:lesson_completion] = api_v1_course_session_lesson_lesson_completion_path(course, session, lesson)
    links[:create_quiz] = api_v1_course_session_lesson_quizzes_path(course, session, lesson) if admin_or_instructor?
    links[:update_lesson] = api_v1_course_session_lesson_path(course, session, lesson) if admin_or_instructor?
    links[:destroy_lesson] = api_v1_course_session_lesson_path(course, session, lesson) if admin_or_instructor?
    links
  end
end
