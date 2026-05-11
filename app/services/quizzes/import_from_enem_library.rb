module Quizzes
  # Cria Questions do tenant a partir de registros globais EnemQuestion (referência por FK).
  class ImportFromEnemLibrary
    Result = Struct.new(:imported_count, :skipped_duplicate_count, :skipped_invalid_count, :error_messages, keyword_init: true)

    def initialize(quiz:, enem_question_ids:)
      @quiz = quiz
      @ids = Array(enem_question_ids).compact_blank.map(&:to_i).uniq
    end

    def call
      imported = 0
      skipped_dup = 0
      skipped_inv = 0
      errors = []

      EnemQuestion.where(id: @ids).includes(:enem_exam).order(:id).each do |eq|
        if @quiz.questions.exists?(enem_question_id: eq.id)
          skipped_dup += 1
          next
        end

        rows = normalize_alternatives(eq)
        letter_up = eq.correct_letter.to_s.upcase.strip

        if rows.size < 2
          skipped_inv += 1
          errors << "Q#{eq.number_in_exam} (#{eq.enem_exam.year}): precisa de pelo menos duas alternativas."
          next
        end

        if rows.count { |r| r[:letter].to_s.upcase == letter_up } != 1
          skipped_inv += 1
          errors << "Q#{eq.number_in_exam} (#{eq.enem_exam.year}): gabarito não bate com as alternativas."
          next
        end

        begin
          ActiveRecord::Base.transaction do
            position = (@quiz.questions.maximum(:position) || -1) + 1
            question = @quiz.questions.build(
              enunciation: compose_enunciation(eq),
              position: position,
              enem_question: eq
            )
            rows.each_with_index do |row, idx|
              question.question_options.build(
                text: row[:text],
                position: idx,
                correct: row[:letter].to_s.upcase == letter_up
              )
            end
            question.save!
          end
          imported += 1
        rescue ActiveRecord::RecordInvalid => e
          skipped_inv += 1
          errors << "Q#{eq.number_in_exam}: #{e.record.errors.full_messages.to_sentence}"
        end
      end

      Result.new(
        imported_count: imported,
        skipped_duplicate_count: skipped_dup,
        skipped_invalid_count: skipped_inv,
        error_messages: errors
      )
    end

    private

    def compose_enunciation(eq)
      exam = eq.enem_exam
      "[ENEM #{exam.year} · #{exam.day} · #{exam.booklet_color} · Q#{eq.number_in_exam} · #{eq.area}]\n\n#{eq.statement}"
    end

    def normalize_alternatives(eq)
      alts = eq.alternatives
      return [] unless alts.is_a?(Array) && alts.any?

      alts.each_with_index.map do |item, i|
        base_letter = ("A".ord + i).chr
        case item
        when Hash
          letter = (item["letter"] || item[:letter] || base_letter).to_s.upcase
          text = (item["text"] || item[:text]).to_s.strip
          text = "(texto da alternativa não informado)" if text.blank?
          { letter: letter, text: "#{letter}) #{text}" }
        when String
          stripped = item.strip
          m = stripped.match(/\A\s*([A-Ea-e])\s*[\).:\-]\s*(.*)\z/m)
          if m
            { letter: m[1].upcase, text: m[2].strip.presence || stripped }
          else
            { letter: base_letter, text: stripped }
          end
        else
          { letter: base_letter, text: item.to_s }
        end
      end
    end
  end
end
