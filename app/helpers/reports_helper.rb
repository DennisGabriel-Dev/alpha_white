# frozen_string_literal: true

module ReportsHelper
  ENEM_AREA_LABELS = {
    "LC" => "Linguagens e códigos",
    "CH" => "Ciências humanas",
    "CN" => "Ciências da natureza",
    "MT" => "Matemática"
  }.freeze

  def reports_area_label(code)
    ENEM_AREA_LABELS.fetch(code.to_s, code.to_s)
  end

  def reports_format_duration(total_seconds)
    return "—" if total_seconds.blank? || total_seconds.to_i.zero?

    seconds = total_seconds.to_i
    minutes = seconds / 60
    remainder = seconds % 60
    if minutes.positive?
      "#{minutes}m #{remainder}s"
    else
      "#{remainder}s"
    end
  end
end
