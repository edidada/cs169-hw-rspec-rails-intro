require 'rails_helper'

describe Movie, type: :model do
  describe 'searching Tmdb by keyword' do
    it 'calls Faraday gem with CS169 domain' do
      expect(Faraday).to receive(:get).with('https://cs169.org')
      Movie.find_in_tmdb('https://cs169.org')
    end

    # WebMock (set up in spec_helper) intercepts the real call and returns
    # the canned "Olympics" result, so no API key is needed here.
    it 'builds Movie objects from a TMDb response' do
      movies = Movie.find_in_tmdb(title: 'Olympics', release_year: '2000', language: 'en')
      expect(movies).to all(be_a Movie)
      expect(movies.size).to eq 2
      expect(movies.map(&:title)).to all(match(/Olympics/))
      expect(movies.map(&:rating)).to all(eq('R'))
    end
  end
end
