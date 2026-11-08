# TMDb lookups shipped for hw-rspec-rails-intro.
# CI never contacts TMDb (WebMock stubs the host), so the placeholder
# key is only used to build the URL that the specs match against.
module TmdbConfig
  API_KEY = ENV.fetch('TMDB_API_KEY', 'invalid-key')
  SEARCH_URI = 'https://api.themoviedb.org/3/search/movie'
end
