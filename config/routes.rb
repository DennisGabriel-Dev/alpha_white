Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Rotas Web (HTML)
  resources :courses do
    resources :sessions, only: [:show, :new, :create, :edit, :update, :destroy] do
      resources :lessons, only: [:show, :new, :create, :edit, :update, :destroy] do
        resources :feedbacks, only: [:create]
        resource :lesson_completion, only: [:create, :update]
        resource :quiz, only: [:new, :create, :edit, :update, :destroy] do
          get :take
          post :submit
          resources :questions, only: [:index, :new, :create, :edit, :update, :destroy]
        end
        delete :destroy_video, on: :member
      end
    end
  end

  # API Routes (JSON)
  namespace :api do
    namespace :v1 do
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
