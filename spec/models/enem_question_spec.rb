# frozen_string_literal: true

require "rails_helper"

RSpec.describe EnemQuestion, type: :model do
  describe "associações" do
    it { should belong_to(:enem_exam) }
  end

  describe "validações" do
    subject { build(:enem_question) }

    it { should validate_presence_of(:number_in_exam) }
    it { should validate_presence_of(:area) }
    it { should validate_presence_of(:statement) }
    it { should validate_presence_of(:correct_letter) }

    it {
      should validate_numericality_of(:number_in_exam)
        .only_integer
        .is_greater_than(0)
    }

    it { should validate_inclusion_of(:area).in_array(described_class::AREA_VALUES) }
    it { should validate_inclusion_of(:correct_letter).in_array(described_class::LETTER_VALUES) }

    it "exige alternatives como array JSON" do
      q = build(:enem_question, alternatives: { "foo" => "bar" })
      expect(q).not_to be_valid
      expect(q.errors[:alternatives]).to be_present
    end

    it "impede número duplicado na mesma prova" do
      exam = create(:enem_exam)
      create(:enem_question, enem_exam: exam, number_in_exam: 5)
      dup = build(:enem_question, enem_exam: exam, number_in_exam: 5)
      expect(dup).not_to be_valid
      expect(dup.errors[:number_in_exam]).to include("has already been taken")
    end
  end
end
