Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :draws, only: %i[index] do
    collection do
      get 'frequencies'
      get 'generate_grid'
    end
  end
end
