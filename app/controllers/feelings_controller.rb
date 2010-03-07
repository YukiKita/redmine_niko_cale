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
  before_filter :find_feeling, :only=>[:show, :edit, :update, :destroy, :edit_comment]
  before_filter :create_feeling, :only=>[:new, :create]

  def index
    users = []
    if @project
      users = @project.users
      @option = {:project=>@project}
    else
      users = find_users
      return render_not_found if users.empty?
      @option = (users.size == 1) ? {:user=>users.first} : {}
    end
    @feeling_pages, @feelings = paginate(:feeling, :per_page => 10, :conditions=>{:user_id=>users}, :order=>"at DESC")
    respond_to do |format|
      format.html {render :layout => false if request.xhr?}
      format.atom {render_feed(@feelings, :title => feeling_list(@option))}
      format.xml  {render :xml=>@feelings}
    end
  end
  def show
    respond_to do |format|
      format.html
      format.xml {render :xml=>@feeling}
    end
  end
  def new
    respond_to do |format|
      format.html
      format.xml {render :xml=>@feeling}
    end
  end
  def edit
    render :template=>"feelings/new"
  end
  def update
    return render_not_found unless set_attributes_for(@feeling)
    with_preview do
      @feeling.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to_index(@feeling, @project)
    end
  end
  def create
    return render_not_found unless set_attributes_for(@feeling)
    with_preview do
      @feeling.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to_index(@feeling, @project)
    end
  end
  def destroy
    @feeling.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to_index(@feeling, @project)
  end

  def edit_comment
    if request.post?
      comments = find_comments
      return render_404 unless comments
      if request.xhr?
        render :partial=>"comment", :locals=>{:comments=>comments}
      else
        if @feeling.add_comment(User.current, comments)
          flash[:notice] = l(:label_comment_added)
        end
        redirect_to_index @feeling, @project
      end
    elsif request.delete?
      flash[:notice] = l(:label_comment_delete)
      begin
        @feeling.comments.find(params[:comment_id]).destroy
        redirect_to_index @feeling, @project    
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    end
  end

  private
  def render_not_found
    respond_to do |format|
      format.html {render_404}
      format.xml {head :status => :unprocessable_entity}
    end
  end
  def create_feeling
    @feeling = Feeling.for(User.current, find_date)
  end
  def with_preview
    if request.xhr?
      if set_attributes_for @feeling
        render :partial=>"show", :locals=>{:feeling=>@feeling, :preview=>true}
      else
        render_404
      end
    else
      yield
    end
  end
  def clean_old_feelings
    retention_period = Setting.plugin_redmine_niko_cale["retention_period"].to_i
    unless retention_period == 0
      Feeling.exclude_before!(retention_period.months.ago.to_date)
    end
  end
  def find_comments
    params[:comment] && params[:comment][:comments]
  end
  def redirect_to_index(feeling, project)
    clean_old_feelings
    respond_to do |format|
      format.html do
        if project
          redirect_to(:controller=>:niko_cale, :action=>:index, :project_id=>project.identifier)
        else
          redirect_to(:action=>:index, :user_id=>feeling.user.id)
        end
      end
      format.xml {head :ok}
    end
  end
  def find_feeling
    begin
      @feeling = Feeling.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found
    end
  end
  def set_attributes_for feeling
    description = (params[:description] || "").strip
    case params[:level]
    when "0"
      feeling.bad(description)
    when "1"
      feeling.ordinary(description)
    when "2"
      feeling.good(description)
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
  def find_user
    begin
      User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
  def find_users
    if params[:user_id]
      User.find_all_by_id(params[:user_id])
    else
      User.all 
    end
  end
end
