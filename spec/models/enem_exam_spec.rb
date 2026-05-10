# frozen_string_literal: true

require "rails_helper"

RSpec.describe EnemExam, type: :model do
  describe "associações" do
    it { should have_many(:enem_questions).dependent(:destroy) }
  end

  describe "validações" do
    subject { build(:enem_exam) }

    it { should validate_presence_of(:year) }
    it { should validate_presence_of(:day) }
    it { should validate_presence_of(:booklet_color) }

    it {
      should validate_numericality_of(:year)
        .only_integer
        .is_greater_than(1990)
        .is_less_than(2100)
    }

    it { should validate_inclusion_of(:day).in_array(described_class::DAY_VALUES) }

    it "exige booklet_color no formato CDn" do
      exam = build(:enem_exam, booklet_color: "invalid")
      expect(exam).not_to be_valid
      expect(exam.errors[:booklet_color]).to be_present
    end

    it "impede duplicata para o mesmo ano, dia e cor" do
      create(:enem_exam, year: 2023, day: "D1", booklet_color: "CD1")
      dup = build(:enem_exam, year: 2023, day: "D1", booklet_color: "CD1")
      expect(dup).not_to be_valid
      expect(dup.errors[:year]).to include("has already been taken")
    end
  end
end
