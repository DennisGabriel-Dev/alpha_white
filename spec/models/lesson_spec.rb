require "rails_helper"

RSpec.describe Lesson, type: :model do
  let(:tenant)  { create(:tenant) }
  let(:course)  { create(:course, tenant: tenant) }
  let(:session) { create(:session, course: course, tenant: tenant) }

  before { set_tenant(tenant) }

  describe "validações" do
    it "é válida com atributos corretos" do
      lesson = build(:lesson, session: session, tenant: tenant)
      expect(lesson).to be_valid
    end

    it { should validate_presence_of(:name) }
  end

  describe "associações" do
    it { should belong_to(:session) }
    it { should belong_to(:tenant).optional }
    it { should have_one(:quiz).dependent(:destroy) }
    it { should have_many(:feedbacks).dependent(:destroy) }
    it { should have_many(:lesson_completions).dependent(:destroy) }
  end

  describe "ordenação padrão" do
    it "ordena por position e id" do
      l2 = create(:lesson, session: session, tenant: tenant, position: 2)
      l1 = create(:lesson, session: session, tenant: tenant, position: 1)
      l3 = create(:lesson, session: session, tenant: tenant, position: 3)

      expect(Lesson.all.to_a).to eq([ l1, l2, l3 ])
    end
  end

  describe "herança do tenant" do
    it "herda o tenant_id da sessão ao ser criada" do
      lesson = Lesson.create!(name: "Aula teste", session: session)
      expect(lesson.tenant_id).to eq(tenant.id)
    end
  end
end
