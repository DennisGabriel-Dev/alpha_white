require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users

  sidekiq_ui = Rack::Builder.new do
    use SidekiqSuperAdminGate
    run Sidekiq::Web
  end
  mount sidekiq_ui, at: "/sidekiq"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API documentation (Swagger UI + OpenAPI spec)
  get "api-docs" => "api_docs#index", as: :api_docs
  get "api-docs/spec" => "api_docs#spec", as: :api_docs_spec

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Configurações do tenant (somente super_admin)
  resource :tenant_setting, only: [:edit, :update]
  resources :enem_import_jobs, only: [:index, :create]
  resources :enem_exams, only: [:index, :show, :edit, :update] do
    resources :enem_questions, only: [:edit, :update], controller: "enem_exam_questions"
  end

  namespace :me, path: "me" do
    get "conquistas", to: "achievements#index", as: :achievements
  end

  scope path: "relatorios", as: :relatorios do
    get "aluno", to: "reports#aluno"
    get "turma", to: "reports#turma"
    get "escola", to: "reports#escola"
  end

  # Rotas Web (HTML)
  resources :courses do
    resources :sessions, only: [:show, :new, :create, :edit, :update, :destroy] do
      resources :lessons, only: [:show, :new, :create, :edit, :update, :destroy] do
        resources :feedbacks, only: [:create]
        resource :lesson_completion, only: [:create, :update]
        resource :quiz, only: [:new, :create, :edit, :update, :destroy] do
          get :take
          get :review
          post :submit
          resources :questions, only: [:index, :new, :create, :edit, :update, :destroy]
          resource :enem_import, only: [:new, :create], controller: "quiz_enem_imports"
        end
        delete :destroy_video, on: :member
      end
    end
  end

  # API Routes (JSON) — autenticação via JWT (Authorization: Bearer <token>)
  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth/sessions#create"

      resources :courses, only: [:index, :show, :create, :update, :destroy] do
        resources :sessions, only: [:index, :show, :create, :update, :destroy] do
          resources :lessons, only: [:index, :show, :create, :update, :destroy] do
            resources :feedbacks, only: [:index, :create]
            resource :lesson_completion, only: [:show, :create, :update]
            resources :quizzes, only: [:index, :show, :create, :update, :destroy] do
              resources :questions, only: [:index, :show, :create, :update, :destroy] do
                resources :question_options, only: [:index, :show, :create, :update, :destroy]
                resources :student_answers, only: [:index, :create, :update]
              end
            end
          end
        end
      end
    end
  end

  # Defines the root path route ("/")
  root "pages#home"
end
