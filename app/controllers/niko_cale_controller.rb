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
class NikoCaleController < ApplicationController
  unloadable
  include FeelingsHelper
  helper :feelings
  before_filter :find_project

  def index
    return authorize unless current_user_allowed?
    @selected_role_ids = find_givable_roles.map{|r| r.id}
    @todays_feeling = Feeling.for(User.current)
    update_information
    @feeling_submittable = feeling_submittable? @project, @givable_roles
  end
  def show
    return redirect_to(:action=>:index, :project_id=>@project) unless request.xhr?
    @selected_role_ids = get_selected_role_ids
    update_information
    render :partial=>"show"
  end
  def submit_feeling
    feeling = Feeling.for(User.current)
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
    redirect_to(:action=>:index, :project_id=>@project)
  end
  private
  def update_information
    @givable_roles = find_givable_roles
    @dates = get_dates
    @with_subprojects = with_subprojects?
    projects = get_projects @project, @with_subprojects
    @users = find_all_users(projects, @selected_role_ids)
    @feelings_per_user, @morales = get_feelings_per_user_and_morales(@users, @dates)
    @issues_count_per_user = issues_count_per_user @users
  end
  def issues_count_per_user users
    open_issue_statuses = IssueStatus.find(:all, :conditions=>{:is_closed=>false})
    users.inject({}) do |result, user|
      issues = Issue.find(:all, :conditions=>{:assigned_to_id=>User.find(user), :status_id=>open_issue_statuses}).size
      result[user] = issues
      result[:morale] = (result[:morale] || 0) + issues
      result
    end
  end
  def feeling_submittable? project, givable_roles
    current_user = User.current
    current_member = project.members.detect{|m| m.user == current_user}
    if current_member
      (!(givable_roles & current_member.roles).empty?)
    else
      false
    end
  end
  def find_project
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
  def find_givable_roles
    Role.find_all_givable.select{|role| role.has_permission?(:submit_feeling)}
  end
  def find_all_users projects, selected_role_ids
    members = projects.inject([]) {|result, project| result + project.members}
    users = members.inject([]) do |result, m|
      if (m.roles.map{|r| r.id} & selected_role_ids).empty?
        result
      else
        result << m.user         
      end
    end.uniq
    current_user =  User.current
    if users.include? current_user
      users.delete(current_user)
      users.unshift(current_user)
    end
    users
  end
  def get_feelings_per_user_and_morales(users, dates)
    morales = []
    feelings_per_user = {}
    unless users.empty?
      morales = dates.map {|date| Morale.new(:at =>date)}
      users.each do |user|
        feelings = Feeling.find_by_user_and_date_range(user, dates)
        feelings_per_user[user] = feelings
        feelings.each do |feeling|
          morales[dates.index(feeling.at)] << feeling
        end
      end
    end
    return feelings_per_user, morales
  end
  def get_selected_role_ids
    (params[:role_ids] || []).map {|r| r.to_i}
  end
  def with_subprojects?
    params[:with_subprojects].nil? ? false : (params[:with_subprojects] == '1')
  end
  def get_projects project, with_subprojects
    with_subprojects ? project.self_and_descendants : [project]
  end
  def get_dates
    begin
      date_scope = params[:date_scope].to_date
    rescue ArgumentError, NoMethodError
      date_scope = Date.today
    end
    ((date_scope - 13)..(date_scope)).map
  end
end
