require "rails_helper"

RSpec.describe "EnemExams", type: :request do
  let(:tenant) { create(:tenant) }
  let(:admin) { create(:user, :tenant_admin, tenant:) }
  let(:instructor) { create(:user, :instructor, tenant:) }
  let(:student) { create(:user, :student, tenant:) }
  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  let!(:exam) { create(:enem_exam, year: 2023, day: "D1", booklet_color: "CD1") }
  let!(:question) { create(:enem_question, enem_exam: exam, number_in_exam: 1, area: "LC", correct_letter: "A") }

  describe "GET /enem_exams" do
    context "como estudante" do
      before { sign_in student }

      it "bloqueia acesso" do
        get enem_exams_path, headers: headers
        expect(response).to redirect_to(root_path)
      end
    end

    context "como admin" do
      before { sign_in admin }

      it "renderiza biblioteca" do
        get enem_exams_path, headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Biblioteca ENEM")
      end
    end
  end

  describe "PATCH /enem_exams/:id" do
    before { sign_in admin }

    it "permite editar prova" do
      patch enem_exam_path(exam),
            params: { enem_exam: { year: 2022, day: "D1", booklet_color: "CD1", metadata_json: "{\"source\":\"manual\"}" } },
            headers: headers

      expect(response).to redirect_to(enem_exam_path(exam))
      expect(exam.reload.year).to eq(2022)
      expect(exam.metadata["source"]).to eq("manual")
    end
  end

  describe "PATCH /enem_exams/:enem_exam_id/enem_questions/:id" do
    before { sign_in instructor }

    it "permite editar questão" do
      patch enem_exam_enem_question_path(exam, question),
            params: {
              enem_question: {
                number_in_exam: 2,
                area: "CH",
                correct_letter: "B",
                skill: "H15",
                statement: "Enunciado ajustado",
                alternatives_json: "[\"A) Alt 1\", \"B) Alt 2\"]"
              }
            },
            headers: headers

      expect(response).to redirect_to(enem_exam_path(exam))
      question.reload
      expect(question.number_in_exam).to eq(2)
      expect(question.area).to eq("CH")
      expect(question.correct_letter).to eq("B")
      expect(question.alternatives).to eq(["A) Alt 1", "B) Alt 2"])
    end
  end
end
