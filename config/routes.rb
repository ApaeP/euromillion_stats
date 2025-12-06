Rails.application.routes.draw do
  # devise_for :users
  root to: 'pages#home'

  resources :draws, only: %i[index] do
    collection do
      get 'frequencies'
      get 'generate_grid'
    end
  end

  # SEO
  get 'sitemap', to: 'sitemaps#show', defaults: { format: :xml }, as: :sitemap
end

