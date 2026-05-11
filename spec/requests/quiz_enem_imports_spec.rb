require "rails_helper"

RSpec.describe "Quiz ENEM imports", type: :request do
  let(:tenant) { create(:tenant) }
  let(:admin) { create(:user, :tenant_admin, tenant:) }
  let(:student) { create(:user, :student, tenant:) }
  let!(:course) { create(:course, tenant:) }
  let!(:session) { create(:session, course:, tenant:) }
  let!(:lesson) { create(:lesson, session:, tenant:) }
  let!(:quiz) { create(:quiz, lesson:, tenant:) }
  let!(:exam_2023) { create(:enem_exam, year: 2023, day: "D1", booklet_color: "CD1") }
  let!(:exam_2022) { create(:enem_exam, year: 2022, day: "D2", booklet_color: "CD7") }
  let!(:eq_2023) do
    create(:enem_question, enem_exam: exam_2023, number_in_exam: 10, area: "LC", correct_letter: "A",
                           alternatives: [
                             { "letter" => "A", "text" => "Alt A" },
                             { "letter" => "B", "text" => "Alt B" }
                           ])
  end
  let!(:eq_2022) do
    create(:enem_question, enem_exam: exam_2022, number_in_exam: 5, area: "CH", correct_letter: "B",
                           alternatives: [
                             { "letter" => "A", "text" => "X" },
                             { "letter" => "B", "text" => "Y" }
                           ])
  end

  let(:headers) { { "HOST" => "#{tenant.subdomain}.lvh.me" } }

  describe "GET .../quiz/enem_import/new" do
    context "como estudante" do
      before { sign_in student }

      it "bloqueia acesso" do
        get new_course_session_lesson_quiz_enem_import_path(course, session, lesson), headers: headers
        expect(response).to redirect_to(root_path)
      end
    end

    context "como admin" do
      before { sign_in admin }

      it "renderiza busca Ransack" do
        get new_course_session_lesson_quiz_enem_import_path(course, session, lesson),
            params: { q: { enem_exam_year_eq: 2023 } },
            headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Importar da Biblioteca ENEM")
        expect(response.body).to include("value=\"#{eq_2023.id}\"")
        expect(response.body).not_to include("value=\"#{eq_2022.id}\"")
      end
    end
  end

  describe "POST .../quiz/enem_import" do
    context "como admin" do
      before { sign_in admin }

      it "importa questões selecionadas" do
        expect do
          post course_session_lesson_quiz_enem_import_path(course, session, lesson),
               params: { enem_question_ids: [ eq_2023.id ] },
               headers: headers
        end.to change { quiz.questions.count }.by(1)

        q = quiz.questions.last
        expect(q.enem_question_id).to eq(eq_2023.id)
        expect(q.question_options.count).to eq(2)
        expect(response).to redirect_to(course_session_lesson_quiz_questions_path(course, session, lesson))
      end

      it "ignora duplicata já na prova" do
        ActsAsTenant.with_tenant(tenant) do
          quiz.questions.create!(
            enunciation: "manual",
            position: 0,
            enem_question: eq_2023,
            question_options_attributes: [
              { text: "a", correct: true, position: 0 },
              { text: "b", correct: false, position: 1 }
            ]
          )
        end

        expect do
          post course_session_lesson_quiz_enem_import_path(course, session, lesson),
               params: { enem_question_ids: [ eq_2023.id ] },
               headers: headers
        end.not_to change { quiz.questions.count }
      end

      it "exige seleção" do
        post course_session_lesson_quiz_enem_import_path(course, session, lesson),
             params: { enem_question_ids: [] },
             headers: headers

        expect(response).to redirect_to(new_course_session_lesson_quiz_enem_import_path(course, session, lesson))
      end
    end
  end
end
