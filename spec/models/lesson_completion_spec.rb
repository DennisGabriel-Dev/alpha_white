require "rails_helper"

RSpec.describe LessonCompletion, type: :model do
  let(:tenant)  { create(:tenant) }
  let(:course)  { create(:course, tenant: tenant) }
  let(:session) { create(:session, course: course, tenant: tenant) }
  let(:lesson)  { create(:lesson, session: session, tenant: tenant) }
  let(:user)    { create(:user, tenant: tenant) }

  before { set_tenant(tenant) }

  describe "validações" do
    it "não permite mais de um registro por (lesson, user)" do
      create(:lesson_completion, lesson: lesson, user: user)
      duplicate = build(:lesson_completion, lesson: lesson, user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:lesson_id]).to be_present
    end
  end

  describe "associações" do
    it { should belong_to(:lesson) }
    it { should belong_to(:user) }
  end

  describe "#completed?" do
    context "quando a aula não tem vídeo nem quiz" do
      it "retorna true mesmo sem nada marcado" do
        completion = create(:lesson_completion, lesson: lesson, user: user)
        expect(completion.completed?).to be true
      end
    end

    context "quando a aula tem vídeo (video_url)" do
      let(:lesson_with_video) { create(:lesson, :with_video_url, session: session, tenant: tenant) }

      it "retorna false se o vídeo não foi assistido" do
        completion = create(:lesson_completion, lesson: lesson_with_video, user: user,
                            video_watched: false)
        expect(completion.completed?).to be false
      end

      it "retorna true quando o vídeo é assistido (sem quiz)" do
        completion = create(:lesson_completion, lesson: lesson_with_video, user: user,
                            video_watched: true)
        expect(completion.completed?).to be true
      end
    end

    context "quando a aula tem quiz" do
      let!(:quiz) { create(:quiz, lesson: lesson, tenant: tenant) }

      it "retorna false se o quiz não foi concluído" do
        completion = create(:lesson_completion, lesson: lesson, user: user,
                            quiz_completed: false)
        expect(completion.completed?).to be false
      end

      it "retorna true quando o quiz é concluído" do
        completion = create(:lesson_completion, lesson: lesson, user: user,
                            quiz_completed: true)
        expect(completion.completed?).to be true
      end
    end
  end

  describe "#watched_video?" do
    it "retorna true se não há vídeo na aula" do
      completion = create(:lesson_completion, lesson: lesson, user: user, video_watched: false)
      expect(completion.watched_video?).to be true
    end

    it "retorna true se video_watched = true" do
      completion = create(:lesson_completion, lesson: lesson, user: user, video_watched: true)
      expect(completion.watched_video?).to be true
    end
  end

  describe "#completed_quiz?" do
    it "retorna true se a aula não tem quiz" do
      completion = create(:lesson_completion, lesson: lesson, user: user, quiz_completed: false)
      expect(completion.completed_quiz?).to be true
    end

    it "retorna false se a aula tem quiz e quiz_completed = false" do
      create(:quiz, lesson: lesson, tenant: tenant)
      completion = create(:lesson_completion, lesson: lesson.reload, user: user,
                          quiz_completed: false)
      expect(completion.completed_quiz?).to be false
    end
  end
end
