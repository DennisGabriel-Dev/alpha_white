require "rails_helper"

RSpec.describe Reports::TenantOverview, type: :model do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:course) { create(:course, tenant:) }
  let!(:session) { create(:session, course:, tenant:) }
  let!(:lesson) { create(:lesson, session:, tenant:) }

  it "conta alunos ativos na janela de 7 dias" do
    LessonCompletion.create!(user: student, lesson:, quiz_completed: false, video_watched: true, updated_at: 1.day.ago)

    result = ActsAsTenant.with_tenant(tenant) do
      Reports::TenantOverview.new(tenant: tenant).call
    end

    expect(result.active_student_count).to eq(1)
  end

  it "retorna engajamento por curso" do
    LessonCompletion.create!(user: student, lesson:, quiz_completed: false, video_watched: true, updated_at: 1.day.ago)

    result = ActsAsTenant.with_tenant(tenant) do
      Reports::TenantOverview.new(tenant: tenant).call
    end

    row = result.engagement_rows.find { |r| r.course.id == course.id }
    expect(row.active_students_7d).to eq(1)
  end
end
