require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with('hardware').
        and_return(@fake_results)
      get :search_tmdb, params: { search_terms: 'hardware' }
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: { search_terms: 'hardware' }
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
  end

  describe 'search behaviors from the hw docs' do
    before :each do
      @fake_results = [double('movie1', title: 'Fake Title', release_date: '1996-12-01',
                              rating: 'R', description: 'Top Noir film')]
    end

    it 'warns when required title is missing' do
      get :search_tmdb, params: { title: '' }
      expect(flash[:warning]).to eq('Please fill in all required fields!')
      expect(response).to redirect_to(movies_path)
    end

    it 'warns when TMDb returns no matching movies' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      get :search_tmdb, params: { title: 'Hardware Fiction' }
      expect(flash[:warning]).to eq('No movies found with given parameters!')
      expect(response).to redirect_to(movies_path)
    end
  end

  describe 'adding a movie from search results' do
    it 'creates the movie and redirects back to the search page with a notice' do
      expect do
        post :add_movie, params: { movie: {
          title: 'Manhunter', rating: 'R',
          description: 'A retired profiler tracks a serial killer.',
          release_date: '1986-08-15'
        } }
      end.to change(Movie, :count).by(1)
      expect(flash[:notice]).to eq('Manhunter was successfully added to RottenPotatoes.')
      expect(response).to redirect_to(search_tmdb_path)
    end
  end
end
