class FeelingsController < ApplicationController
  unloadable
  helper :niko_cale
  def show
    @feeling = find_feeling
    unless @feeling
      render_404
    end
  end

  def find_feeling
    begin
      Feeling.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end
