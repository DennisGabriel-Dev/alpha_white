# frozen_string_literal: true

# Oculta gabarito (campo `correct`) na API para alunos.
module ApiQuizSecrecy
  extend ActiveSupport::Concern

  private

  def staff_api_user?
    current_user&.super_admin? || current_user&.tenant_admin? || current_user&.instructor?
  end

  def serialize_question_option(option)
    option.as_json.tap do |json|
      json.except!("correct") unless staff_api_user?
    end
  end

  def serialize_question_options(options)
    options.map { |option| serialize_question_option(option) }
  end

  def serialize_question(question, include_options: true)
    question.as_json.tap do |json|
      next unless include_options

      json["question_options"] = serialize_question_options(question.question_options)
    end
  end
end
