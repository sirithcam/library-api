Rails.application.routes.draw do
  namespace :api do
    devise_for :users, controllers: {
      registrations: 'api/users/registrations',
      sessions: 'api/users/sessions',
      passwords: 'api/users/passwords'
    }

    resources :users, only: [:show, :update]
  end
end
