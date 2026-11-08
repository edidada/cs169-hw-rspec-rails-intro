Rails.application.routes.draw do
  # hw-rspec-rails-intro: TMDb lookup flow.
  # GET /search is the search form; submitting it hits search_tmdb; the
  # per-result Add button posts to add_movie. Movie CRUD stays intact.
  get 'search', to: 'movies#search_tmdb', as: 'search_tmdb'
  post 'add_movie', to: 'movies#add_movie', as: 'add_movie'

  resources :movies
  root :to => redirect('/movies')
end
