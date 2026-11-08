require 'faraday'
require 'json'

class Movie < ApplicationRecord
  # TmdbConfig::API_KEY and TmdbConfig::SEARCH_URI are set in
  # config/initializers/themoviedb.rb; the specs never hit TMDb (WebMock).

  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  # TMDb lookup.
  #
  # * String parameters are treated as an already-formed URI and are
  #   fetched as-is (the hw walkthrough's `Faraday.get url` behavior).
  # * Hash parameters are expected to have :title plus optional
  #   :release_year and :language keys, and are turned into a proper
  #   /search/movie query before being fetched.
  #
  # Returns a list of unsaved Movie records; the TMDb search endpoint
  # does not carry MPAA ratings, so every record defaults to "R".
  def self.find_in_tmdb(params)
    if params.is_a?(String) && params.start_with?('http')
      return Faraday.get(params)
    end

    search = params.is_a?(ActionController::Parameters) ? params.to_unsafe_h : params.to_h
    query = { api_key: TmdbConfig::API_KEY, query: search[:title].to_s }
    query[:year] = search[:release_year].to_s if search[:release_year].present?
    query[:language] = search[:language].to_s if search[:language].present?

    response = Faraday.get(TmdbConfig::SEARCH_URI.to_s, query)
    body = response.body.present? ? JSON.parse(response.body) : {}
    results = body['results']
    return [] if results.nil? || results.empty?

    results.map do |movie|
      Movie.new(
        title: movie['title'] || movie['original_title'],
        release_date: movie['release_date'],
        rating: 'R',
        description: movie['overview']
      )
    end
  end
end
