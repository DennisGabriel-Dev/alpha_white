require "rails_helper"

RSpec.describe Quiz, type: :model do
  let(:tenant)  { create(:tenant) }
  let(:course)  { create(:course, tenant: tenant) }
  let(:session) { create(:session, course: course, tenant: tenant) }
  let(:lesson)  { create(:lesson, session: session, tenant: tenant) }

  before { set_tenant(tenant) }

  describe "validações" do
    it { should validate_presence_of(:title) }

    it "é válido com título e lesson associada" do
      quiz = build(:quiz, lesson: lesson, tenant: tenant)
      expect(quiz).to be_valid
    end
  end

  describe "associações" do
    it { should belong_to(:lesson) }
    it { should belong_to(:tenant).optional }
    it { should have_many(:questions).dependent(:destroy) }
  end

  describe "herança do tenant" do
    it "herda o tenant_id da lesson ao ser criado" do
      quiz = Quiz.create!(title: "Prova teste", lesson: lesson)
      expect(quiz.tenant_id).to eq(tenant.id)
    end
  end
end
