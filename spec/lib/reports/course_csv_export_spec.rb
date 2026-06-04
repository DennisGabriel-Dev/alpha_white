# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::CourseCsvExport, type: :model do
  let(:tenant) { create(:tenant) }
  let(:student) { create(:user, :student, tenant:, email: "aluno@demo.com") }
  let!(:course) { create(:course, tenant:, name: "ENEM Turbo") }
  let!(:session) { create(:session, course:, tenant:, name: "Módulo 1") }
  let!(:lesson) { create(:lesson, session:, tenant:, name: "Aula 1") }
  let!(:quiz) { create(:quiz, lesson:, tenant:, title: "Prova 1") }
  let!(:question) do
    create(:question, quiz:, tenant:, position: 0, enunciation: "Questão de teste",
                      question_options_attributes: [
                        { text: "Certa", correct: true, position: 0 },
                        { text: "Errada", correct: false, position: 1 }
                      ])
  end

  before do
    opt = question.question_options.find_by!(correct: true)
    create_submitted_answer(
      user: student,
      question: question,
      question_option: opt,
      started_at: Time.zone.parse("2026-05-01 10:00"),
      submitted_at: Time.zone.parse("2026-05-01 10:05")
    ).tap do |attempt|
      attempt.student_answers.first.update!(time_spent_seconds: 90)
    end
  end

  it "gera CSV com colunas esperadas" do
    csv = described_class.new(course: course, tenant: tenant).call
    rows = CSV.parse(csv, col_sep: ";", headers: true)

    expect(rows.size).to eq(1)
    expect(rows[0]["email"]).to eq("aluno@demo.com")
    expect(rows[0]["curso"]).to eq("ENEM Turbo")
    expect(rows[0]["aula"]).to eq("Aula 1")
    expect(rows[0]["acertou"]).to eq("sim")
    expect(rows[0]["tempo_questao_seg"]).to eq("90")
    expect(rows[0]["tempo_prova_seg"]).to eq("300")
    expect(rows[0]["tentativas_questao"]).to eq("1")
  end

  it "filtra por período quando informado" do
    csv = described_class.new(
      course: course,
      tenant: tenant,
      from: Date.parse("2026-06-01"),
      to: Date.parse("2026-06-30")
    ).call
    rows = CSV.parse(csv, col_sep: ";", headers: true)

    expect(rows.size).to eq(0)
  end
end
