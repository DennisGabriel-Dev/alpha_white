require "rails_helper"

RSpec.describe Gamification::RecordActivity do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }

  it "inicia streak no primeiro dia" do
    streak = ActsAsTenant.with_tenant(tenant) do
      described_class.new(user: student, tenant: tenant).call
    end

    expect(streak.current_streak).to eq(1)
    expect(streak.longest_streak).to eq(1)
    expect(streak.last_activity_on).to eq(Time.zone.today)
  end

  it "não incrementa duas vezes no mesmo dia" do
    ActsAsTenant.with_tenant(tenant) do
      described_class.new(user: student, tenant: tenant).call
      streak = described_class.new(user: student, tenant: tenant).call
      expect(streak.current_streak).to eq(1)
    end
  end

  it "incrementa no dia seguinte" do
    ActsAsTenant.with_tenant(tenant) do
      StudyStreak.create!(user: student, tenant: tenant, current_streak: 1, longest_streak: 1, last_activity_on: Time.zone.yesterday)
      streak = described_class.new(user: student, tenant: tenant).call
      expect(streak.current_streak).to eq(2)
    end
  end

  it "reinicia após gap de dois dias" do
    ActsAsTenant.with_tenant(tenant) do
      StudyStreak.create!(user: student, tenant: tenant, current_streak: 5, longest_streak: 5, last_activity_on: 3.days.ago.to_date)
      streak = described_class.new(user: student, tenant: tenant).call
      expect(streak.current_streak).to eq(1)
    end
  end

  it "ignora não-aluno" do
    instructor = create(:user, :instructor, tenant: tenant)
    expect(described_class.new(user: instructor, tenant: tenant).call).to be_nil
  end
end
