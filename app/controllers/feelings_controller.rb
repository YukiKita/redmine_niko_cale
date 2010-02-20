class FeelingsController < ApplicationController
  unloadable
  helper :niko_cale
  def index
    @feelings = Feeling.find([2, 4])
  end
  def show
    begin
      @feeling = Feeling.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
