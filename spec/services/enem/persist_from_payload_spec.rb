require "rails_helper"

RSpec.describe Enem::PersistFromPayload do
  subject(:service) { described_class.new }

  let(:payload) do
    {
      "exam" => {
        "year" => 2023,
        "day" => "D1",
        "booklet_color" => "CD1",
        "metadata" => { "source" => "inep" }
      },
      "questions" => [
        {
          "number_in_exam" => 1,
          "area" => "LC",
          "statement" => "Enunciado 1",
          "alternatives" => [{ "letter" => "A", "text" => "Alt A" }],
          "correct_letter" => "A"
        }
      ]
    }
  end

  it "persiste prova e questões de forma idempotente" do
    expect { service.call(payload:) }.to change(EnemExam, :count).by(1)
      .and change(EnemQuestion, :count).by(1)

    expect { service.call(payload:) }.to change(EnemExam, :count).by(0)
      .and change(EnemQuestion, :count).by(0)
  end
end
