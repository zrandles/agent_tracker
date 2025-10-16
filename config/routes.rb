Rails.application.routes.draw do
  scope path: '/agent_tracker' do
    root "dashboard#index"

    resources :agents, only: [:index, :show]
    resources :agent_invocations, only: [:index, :show, :new, :create]
    resources :agent_issues, only: [:index, :show]
    resources :agent_improvements, only: [:index, :show]
    resources :agent_changes, only: [:index]

    # Quick log form shortcut
    get '/quick_log', to: 'agent_invocations#new', as: :quick_log

    # API endpoints (no /agent_tracker scope - at root level)
    namespace :api do
      resources :agent_invocations, only: [] do
        collection do
          post :bulk_create
        end
      end
    end

    get "up" => "rails/health#show", as: :rails_health_check
  end
end
