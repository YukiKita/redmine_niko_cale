class FeelingsController < ApplicationController
  unloadable
  helper :niko_cale
  def show
    begin
      @feeling = Feeling.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
