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
  before_filter :find_project, :authorize_global

  def index
    if request.xhr?
      @selected_role_ids = get_selected_role_ids
      update_information
      render :partial=>"show"
    else
      @selected_role_ids = find_givable_roles.map{|role| role.id}
      update_information
    end
  end
  private
  def update_information
    @givable_roles = find_givable_roles
    @dates = get_dates
    @with_subprojects = with_subprojects?
    projects = get_projects @project, @with_subprojects
    @users = find_all_users(projects, @selected_role_ids)
    @feelings_per_user, @morales = get_feelings_per_user_and_morales(@users, @dates)
    @issues_count_per_user = issues_count_per_user @users, @project
    @versions = Version.find(:all, :conditions=>["project_id =? and effective_date >= ? and effective_date <= ?", @project, @dates.first, @dates.last], :order=>"effective_date ASC")
  end
  def issues_count_per_user users, project
    open_issue_statuses = IssueStatus.find_all_by_is_closed(false)
    users.inject({}) do |result, user|
      issues = Issue.find_all_by_assigned_to_id_and_status_id_and_project_id(User.find(user), open_issue_statuses, project).size
      result[user] = issues
      result
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
    Role.find_all_givable.select{|role| role.has_permission?(:edit_feelings)}
  end
  def find_all_users projects, selected_role_ids
    members = projects.inject([]) {|result, project| result + project.members}
    users = members.inject([]) do |result, member|
      if (member.roles.map{|role| role.id} & selected_role_ids).empty?
        result
      else
        result << member.user
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
    (params[:role_ids] || []).map {|role_id| role_id.to_i}
  end
  def with_subprojects?
    with_subproject = params[:with_subprojects]
    with_subproject && (with_subproject == '1')
  end
  def get_projects project, with_subprojects
    with_subprojects ? project.self_and_descendants : [project]
  end
  def get_dates
    begin
      date_scope = params[:date_scope].to_date
    rescue ArgumentError, NoMethodError
      default_date_scope = (Setting.plugin_redmine_niko_cale[:default_date_scope] || '0').to_i
      date_scope = Date.today + default_date_scope
    end
    ((date_scope - 13)..(date_scope)).map
  end
end
