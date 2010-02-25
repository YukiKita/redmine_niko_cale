# Niko-cale plugin for Redmine
# Copyright (C) 2010  Yuki Kita
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
class FeelingsController < ApplicationController
  unloadable
  include FeelingsHelper
  before_filter :find_project, :authorize_global

  def index
    users = []
    if @project
      users = find_users_for @project
      @option = {:project=>@project}
    else
      users = find_users
      return render_404 if users.empty?
      @option = (users.size == 1) ? {:user=>users.first} : {}
    end
    @feeling_pages, @feelings = paginate(:feeling, :per_page => 10, :conditions=>{:user_id=>users}, :order=>"at DESC")
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.atom { render_feed(@feelings, :title => feeling_list(@option)) }
    end
  end
  def show
    begin
      @feeling = Feeling.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
  def edit
    @date = find_date
    @feeling = Feeling.for(User.current, @date)
    return render_404 unless editable?(@feeling)
    if request.xhr?
      if set_attributes_for @feeling
        render :partial=>"show", :locals=>{:feeling=>@feeling, :preview=>true}
      else
        render_404 
      end
    elsif request.get?
    elsif request.delete?
      @feeling.destroy
      redirect_to_index(@project)
    else
      return render_404 unless set_attributes_for(@feeling)
      @feeling.save
      redirect_to_index(@project)
    end
  end

  private
  def redirect_to_index project
    flash[:notice] = l(:notice_successful_update)
    if project
      redirect_to(:controller=>:niko_cale, :action=>:index, :project_id=>project.id)
    else
      redirect_to(:action=>:index, :user_id=>User.current)
    end
  end
  def set_attributes_for feeling
    comment = (params[:comment] || "").strip
    case params[:level]
    when "0"
      feeling.bad(comment)
    when "1"
      feeling.ordinary(comment)
    when "2"
      feeling.good(comment)
    else
      nil
    end
  end
  def find_date
    begin
      date = params[:date].to_date
    rescue ArgumentError, NoMethodError
      date = Date.today
    end
  end
  def find_project
    return unless params[:project_id]
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
  def find_users_for project
    members = Member.find_all_by_project_id(project)
    members.map{|member| member.user}
  end
  def find_users
    if params[:user_id]
      User.find_all_by_id(params[:user_id])
    else
      User.all 
    end
  end
end
