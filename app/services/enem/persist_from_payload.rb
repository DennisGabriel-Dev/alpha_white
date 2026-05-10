module Enem
  class PersistFromPayload
    class Error < StandardError; end

    def call(payload:)
      exam_data = payload.fetch("exam") { payload.fetch(:exam) }
      questions_data = payload.fetch("questions") { payload.fetch(:questions, []) }

      ActiveRecord::Base.transaction do
        exam = upsert_exam(exam_data)
        upsert_questions(exam:, questions_data:)
        exam
      end
    rescue KeyError => e
      raise Error, "Missing payload key: #{e.message}"
    end

    private

    def upsert_exam(exam_data)
      year = fetch_key(exam_data, :year)
      day = fetch_key(exam_data, :day)
      booklet_color = fetch_key(exam_data, :booklet_color)
      metadata = fetch_key(exam_data, :metadata, default: {})

      exam = EnemExam.find_or_initialize_by(year:, day:, booklet_color:)
      exam.metadata = metadata || {}
      exam.save!
      exam
    end

    def upsert_questions(exam:, questions_data:)
      questions_data.each do |q|
        number_in_exam = fetch_key(q, :number_in_exam)
        question = EnemQuestion.find_or_initialize_by(enem_exam: exam, number_in_exam:)
        question.area = fetch_key(q, :area)
        question.skill = fetch_key(q, :skill, default: nil)
        question.statement = fetch_key(q, :statement)
        question.alternatives = fetch_key(q, :alternatives, default: [])
        question.correct_letter = fetch_key(q, :correct_letter)
        question.save!
      end
    end

    def fetch_key(hash, key, default: :__missing__)
      return hash[key.to_s] if hash.key?(key.to_s)
      return hash[key] if hash.key?(key)
      return default unless default == :__missing__

      raise KeyError, key.to_s
    end
  end
end
