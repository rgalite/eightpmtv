class GenresController < ApplicationController
  def show
    @genre = Genre.find(params[:id])
  end

  def index
    @genres = Genre.all
  end
end
