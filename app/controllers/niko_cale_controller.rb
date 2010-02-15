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
    date_scope = get_date_scope
    @givable_roles = find_givable_roles
    @selected_role_ids = get_selected_role_ids(@givable_roles)
    @dates = ((date_scope - 13)..(date_scope)).map
    @with_subprojects = params[:with_subprojects].nil? ? false : (params[:with_subprojects] == '1')
    projects = @with_subprojects ? @project.self_and_descendants : [@project]
    @users = find_all_users(projects)
    @feelings_per_user, @moods = get_feelings_per_user_and_moods(@users, @dates)
  end
  def submit_feeling
    feeling = Feeling.for(User.current)
    case params[:level].to_i
    when 0
      feeling.bad!(params[:comment])
    when 1
      feeling.ordinary!(params[:comment])
    when 2
      feeling.good!(params[:comment])
    else
      raise "must not happen"
    end
    redirect_to(:action=>:index, :project_id=>params[:project_id])
  end
  private
  def find_project
    @project = Project.find(params[:project_id])
  end
  def find_givable_roles
    Role.find_all_givable
  end
  def get_date_scope
    begin
      date_scope = params[:date_scope].to_date
    rescue ArgumentError, NoMethodError
      date_scope = Date.today
    end
  end
  def find_all_users projects
    members = projects.inject([]) {|result, project| result + project.members}.uniq
    users = members.inject([]) do |result, m|
      if (m.roles.map{|r| r.id} & @selected_role_ids).empty?
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
    (params[:role_ids] || @givable_roles.map{|r| r.id}).map{|r| r.to_i}
  end
end
