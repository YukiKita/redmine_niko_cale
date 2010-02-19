class FeelingsController < ApplicationController
  unloadable
  def show
    @feeling = find_feeling
    unless @feeling
      flash[:error] = l(:label_niko_cale_notice_error)
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
