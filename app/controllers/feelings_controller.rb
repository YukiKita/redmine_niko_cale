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
  before_filter :authorize_global

  def index
    project = find_project
    users = []
    if project
      users = find_users_for project
      @option = {:project=>project}
    else
      users = find_users
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
    @project = find_project
  end
  def update
    @date = find_date
    feeling = Feeling.for(User.current, @date)
    comment = (params[:comment] || "").strip
    case params[:level]
    when "0"
      feeling.bad!(comment)
      flash[:notice] = l(:label_niko_cale_notice_success)
    when "1"
      feeling.ordinary!(comment)
      flash[:notice] = l(:label_niko_cale_notice_success)
    when "2"
      feeling.good!(comment)
      flash[:notice] = l(:label_niko_cale_notice_success)
    else
      flash[:error] = l(:label_niko_cale_notice_error)
    end
    @project = find_project
    if @project
      redirect_to(:controller=>:niko_cale, :action=>:index, :project_id=>@project)
    else
      redirect_to(:action=>:show, :id=>feeling.id)
    end
  end

  private
  def find_date
    begin
      date = params[:date].to_date
    rescue ArgumentError, NoMethodError
      date = Date.today
    end
    delta = (Date.today - date)
    return render_404 unless  ((0 <= delta) && (delta < 3))
    date
  end
  def find_project
    return nil unless params[:project_id]
    begin
      Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
  def find_users_for project
    members = Member.find(:all, :conditions=>{:project_id => project})
    members.map{|member| member.user}
  end
  def find_users
    return User.find(:all) unless params[:user_id]
    begin
      User.find(:all, :conditions=>{:id=>params[:user_id]})
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
