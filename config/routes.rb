Rails.application.routes.draw do
  namespace :api do
    devise_for :users, controllers: {
      registrations: 'api/users/registrations',
      sessions: 'api/users/sessions',
      passwords: 'api/users/passwords'
    }

    put '/users/:id/promote', to: 'users#promote', as: 'promote_user'
    put '/users/:id/toggle_admin', to: 'api/users#toggle_admin', as: 'toggle_admin'

    delete '/users/logout', to: 'users#logout', as: 'logout'

    resources :users, only: %i[show update destroy index logout]
  end
end
