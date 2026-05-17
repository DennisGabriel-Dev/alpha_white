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
end
