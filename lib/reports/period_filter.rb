# frozen_string_literal: true

module Reports
  class PeriodFilter
    def self.parse(from_param, to_param)
      from = parse_date(from_param)&.beginning_of_day
      to = parse_date(to_param)&.end_of_day
      new(from:, to:)
    end

    def initialize(from: nil, to: nil)
      @from = from
      @to = to
    end

    attr_reader :from, :to

    def apply_to_quiz_attempts(scope)
      scoped = scope
      scoped = scoped.where("quiz_attempts.submitted_at >= ?", @from) if @from
      scoped = scoped.where("quiz_attempts.submitted_at <= ?", @to) if @to
      scoped
    end

    private

    def self.parse_date(value)
      return nil if value.blank?

      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
