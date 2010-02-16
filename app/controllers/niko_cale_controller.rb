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

  def index
    find_project
    @givable_roles = find_givable_roles
    @selected_role_ids = get_selected_role_ids(@givable_roles)
    @dates = get_dates
    @with_subprojects = with_subprojects?
    projects = get_projects @project, @with_subprojects
    @users = find_all_users(projects, @selected_role_ids)
    @feelings_per_user, @moods = get_feelings_per_user_and_moods(@users, @dates)
    @feeling_submittable = feeling_submittable? @project, @givable_roles
    @todays_feeling = Feeling.for(User.current)
    @issues_count_per_user = issues_count_per_user @users
  end
  def submit_feeling
    feeling = Feeling.for(User.current)
    message = nil
    case params[:level].to_i
    when 0
      message = :bad!
    when 1
      message = :ordinary!
    when 2
      message = :good!
    else
      raise "must not happen"
    end
    feeling.__send__(message, params[:comment])
    flash[:notice] = l(:notice_successful_update)
    redirect_to(:action=>:index, :project_id=>params[:project_id])
  end
  private
  def issues_count_per_user users
    open_issue_statuses = IssueStatus.find(:all, :conditions=>{:is_closed=>false})
    users.inject({}) do |result, user|
      issues = Issue.find(:all, :conditions=>{:assigned_to_id=>User.find(user), :status_id=>open_issue_statuses}).size
      result[user] = issues
      result[:mood] = (result[:mood] || 0) + issues
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
    @project = Project.find(params[:project_id])
  end
  def find_givable_roles
    Role.find_all_givable.select{|role| role.has_permission?(:submit_feeling)}
  end
  def find_all_users projects, selected_role_ids
    members = projects.inject([]) {|result, project| result + project.members}.uniq
    users = members.inject([]) do |result, m|
      if (m.roles.map{|r| r.id} & selected_role_ids).empty?
        result
      else
        result << m.user         
      end
    end
    if users.include? User.current
      users.delete(User.current)
      users.unshift(User.current)
    end
    users
  end
  def get_feelings_per_user_and_moods(users, dates)
    moods = []
    feelings_per_user = {}
    unless users.empty?
      moods = dates.map {|date| Mood.new(:at =>date)}
      users.each do |user|
        feelings = Feeling.find_by_user_and_date_range(user, dates)
        feelings_per_user[user] = feelings
        feelings.each do |feeling|
          moods[dates.index(feeling.at)] << feeling
        end
      end
    end
    return feelings_per_user, moods
  end
  def get_selected_role_ids givable_roles
    (params[:role_ids] || givable_roles.map{|r| r.id}).map{|r| r.to_i}
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
