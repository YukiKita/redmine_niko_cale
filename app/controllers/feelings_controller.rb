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
  helper FeelingsHelper
  before_filter :find_project, :authorize_global
  before_filter :find_feeling, :only => [:show, :edit, :update, :destroy, :edit_comment]
  before_filter :create_feeling, :only => [:new, :create]
  before_filter :render_feeling, :only => [:new, :show]

  def index
    if @project
      users = @project.users
      @option = {:project => @project}
    else
      users = find_users
      return render_not_found if users.empty?
      @option = (users.size == 1) ? {:user => users.first} : {}
    end

    scope = Feeling.where(user_id: users)
    @limit = 10
    @feeling_count = scope.count
    @feeling_pages = Paginator.new @feeling_count, @limit, params['page']
    @offset ||= @feeling_pages.offset
    @feelings = scope.order('at DESC').limit(@limit).offset(@offset).to_a

    respond_to do |format|
      format.html {render :layout => false if request.xhr?}
      format.atom {render_feed(@feelings, :title => feeling_list(@option))}
      format.xml {render :xml => @feelings}
    end
  end

  def show
  end

  def new
  end

  def edit
    render :template => "feelings/new"
  end

  def update
    save_feeling l(:notice_successful_update)
  end

  def create
    save_feeling l(:notice_successful_create)
  end

  def destroy
    @feeling.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to_index(@feeling, @project)
  end

  def edit_comment
    if request.post?
      post_comment
    elsif request.delete?
      delete_comment
    end
  end

  private

  def post_comment
    comments = find_comments
    return render_404 unless comments
    if request.xhr?
      render :partial => "comment", :locals => {:comments => comments}
    else
      comment = @feeling.add_comment(User.current, comments)
      if comment
        FeelingsMailer.feeling_commented(comment).deliver
        flash[:notice] = l(:label_comment_added)
      end
      redirect_to_index @feeling, @project
    end
  end

  def delete_comment
    flash[:notice] = l(:label_comment_delete)
    begin
      @feeling.comments.find(params[:comment_id]).destroy
      redirect_to_index @feeling, @project
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  def render_feeling
    respond_to do |format|
      format.html
      format.xml {render :xml => @feeling}
    end
  end

  def render_not_found
    respond_to do |format|
      format.html {render_404}
      format.xml {head :status => :unprocessable_entity}
    end
  end

  def create_feeling
    @feeling = Feeling.for(User.current, find_date)
  end

  def save_feeling message
    return render_not_found unless set_attributes_for(@feeling)
    if request.xhr?
      render :partial => "show", :locals => {:feeling => @feeling, :preview => true}
    else
      @feeling.save
      flash[:notice] = message
      redirect_to_index(@feeling, @project)
    end
  end

  def clean_old_feelings
    retention_period = Setting.plugin_redmine_niko_cale["retention_period"].to_i
    unless retention_period == 0
      Feeling.exclude_before!(retention_period.months.ago.to_date)
    end
  end

  def find_comments
    comment = params[:comment]
    comment && comment[:comments]
  end

  def redirect_to_index(feeling, project)
    clean_old_feelings
    respond_to do |format|
      format.html do
        if project
          redirect_to(:controller => :niko_cale, :action => :index, :project_id => project.identifier)
        else
          redirect_to(:action => :index, :user_id => feeling.user.id)
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
    new_feeling = params['feeling']
    level = new_feeling['level']
    return nil unless new_feeling && level
    description = (new_feeling['description'] || '').strip
    case level.to_i
    when 0
      feeling.bad(description)
    when 1
      feeling.ordinary(description)
    when 2
      feeling.good(description)
    else
      nil
    end
  end

  def find_date
    begin
      date = params["feeling"]["at"].to_date
    rescue ArgumentError, NoMethodError
      date = Date.today
    end
  end

  def find_project
    project_id = params[:project_id]
    return unless project_id
    begin
      @project = Project.find(project_id)
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
    user_id = params[:user_id]
    user_id ? User.where(id: user_id) : User.all
  end
end
