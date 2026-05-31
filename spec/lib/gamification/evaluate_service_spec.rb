require "rails_helper"

RSpec.describe Gamification::EvaluateService do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:first_answer) { Achievement.find_or_create_by!(slug: "first_answer") { |a| a.assign_attributes(name: "FA", description: "d", kind: :event, threshold: 1) } }
  let!(:streak_3) { Achievement.find_or_create_by!(slug: "streak_3") { |a| a.assign_attributes(name: "S3", description: "d", kind: :streak, threshold: 3) } }

  before { ensure_achievements_catalog! }

  it "concede first_answer na primeira resposta" do
    course = create(:course, tenant: tenant)
    session = create(:session, course:, tenant: tenant)
    lesson = create(:lesson, session:, tenant: tenant)
    quiz = create(:quiz, lesson:, tenant: tenant)
    q = build(:question, quiz:, tenant: tenant)
    q.question_options.build(text: "A", correct: true, position: 0)
    q.question_options.build(text: "B", correct: false, position: 1)
    q.save!
    opt = q.question_options.find_by!(correct: true)

    ActsAsTenant.with_tenant(tenant) do
      create_submitted_answer(user: student, question: q, question_option: opt)
      result = described_class.new(user: student, tenant: tenant).call
      expect(result.newly_awarded.map(&:slug)).to include("first_answer")
    end
  end

  it "não duplica badge" do
    ActsAsTenant.with_tenant(tenant) do
      UserAchievement.create!(user: student, achievement: first_answer, tenant: tenant)
      result = described_class.new(user: student, tenant: tenant)
      expect(result.call.newly_awarded.map(&:slug)).not_to include("first_answer")
    end
  end

  it "concede first_answer mesmo com várias respostas já salvas" do
    course = create(:course, tenant: tenant)
    session = create(:session, course:, tenant: tenant)
    lesson = create(:lesson, session:, tenant: tenant)
    quiz = create(:quiz, lesson:, tenant: tenant)

    2.times do
      q = build(:question, quiz:, tenant: tenant)
      q.question_options.build(text: "A", correct: true, position: 0)
      q.question_options.build(text: "B", correct: false, position: 1)
      q.save!
      opt = q.question_options.find_by!(correct: true)
      create_submitted_answer(user: student, question: q, question_option: opt)
    end

    ActsAsTenant.with_tenant(tenant) do
      result = described_class.new(user: student, tenant: tenant, quiz: quiz).call
      expect(result.newly_awarded.map(&:slug)).to include("first_answer")
    end
  end
end
