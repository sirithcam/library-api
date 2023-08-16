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

    get '/books/search', to: 'books#search', as: 'search_books'


    get '/books/:book_id/reviews', to: 'reviews#index', as: 'index'
    put '/books/:book_id/reviews', to: 'reviews#update', as: 'update'
    delete '/books/:book_id/reviews', to: 'reviews#delete', as: 'delete'

    delete '/reviews/:id', to: 'reviews#admin_delete_review', as: 'admin_delete_review'

    resources :users, only: %i[show update destroy index logout]
    resources :books, only: %i[create update destroy show index] do
      resources :reviews, only: [:create]
    end
    resources :purchase_intents, only: %i[create destroy show index update] do
      member do
        post :send_intent
      end
    end
    resources :purchases, only: [:index] do
      member do
        post :process_purchase
      end
    end
  end
end
