# frozen_string_literal: true

require "rails_helper"

RSpec.describe Question, type: :model do
  let(:tenant)  { create(:tenant) }
  let(:course)  { create(:course, tenant: tenant) }
  let(:session) { create(:session, course: course, tenant: tenant) }
  let(:lesson)  { create(:lesson, session: session, tenant: tenant) }
  let(:quiz)    { create(:quiz, lesson: lesson, tenant: tenant) }

  before { set_tenant(tenant) }

  describe "associações" do
    it { should belong_to(:enem_question).optional }
  end

  describe "#from_enem?" do
    it "retorna false sem enem_question" do
      q = build(:question, quiz: quiz, tenant: tenant, enem_question: nil)
      expect(q.from_enem?).to be(false)
    end

    it "retorna true com enem_question" do
      eq_record = create(:enem_question)
      q = build(:question, quiz: quiz, tenant: tenant, enem_question: eq_record)
      expect(q.from_enem?).to be(true)
    end
  end
end
