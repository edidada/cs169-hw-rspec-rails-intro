class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings

    raw_ratings = params[:ratings]

    raw_ratings = raw_ratings.keys if raw_ratings.is_a?(ActionController::Parameters) ||
                                      raw_ratings.is_a?(Hash)

    if raw_ratings.present?
      @ratings_to_show = Array(raw_ratings).reject(&:blank?)
      session[:ratings] = @ratings_to_show
    else
      @ratings_to_show = session[:ratings] || @all_ratings
    end

    sort_param = params[:sort_by].presence_in(%w[title release_date])

    if sort_param
      @sort_by = sort_param
      session[:sort_by] = @sort_by
    else
      @sort_by = session[:sort_by] || "title"
    end

    @movies = Movie.with_ratings(@ratings_to_show, @sort_by)
  end

  # GET /search: the TMDb lookup form.
  def search_tmdb
    if params[:search_terms].present?
      # The hw walkthrough's TDD spec drives find_in_tmdb with a string of
      # search terms, so honor that first.
      args = params[:search_terms].to_s
    elsif params[:title].blank?
      flash[:warning] = 'Please fill in all required fields!'
      redirect_to movies_path
      return
    else
      args = { title: params[:title].strip }
      args[:release_year] = params[:release_year] if params[:release_year].present?
      args[:language] = params[:language] if params[:language].present?
    end

    @movies = Movie.find_in_tmdb(args)

    if @movies.blank?
      flash[:warning] = 'No movies found with given parameters!'
      redirect_to movies_path
      return
    end
    # Falls through to render search_tmdb.html.erb, which shows the results
    # table plus the per-result Add form.
  end

  # POST /add_movie: create a movie from a single TMDb search result.
  def add_movie
    attrs = movie_params
    @movie = Movie.create!(attrs)
    flash[:notice] = "#{@movie.title} was successfully added to RottenPotatoes."
    redirect_to search_tmdb_path
  end

  # GET /movies/new or /movies.json
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
