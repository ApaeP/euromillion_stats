Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :tirages
  get 'index_per_year', to: 'pages#index_per_year'
  get 'frequencies', to: 'pages#frequencies'
end
