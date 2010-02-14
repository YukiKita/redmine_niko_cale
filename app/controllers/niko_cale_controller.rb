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
    begin
      date_scope = params[:date_scope].to_date
    rescue ArgumentError, NoMethodError
      date_scope = Date.today
    end
    @givable_roles = Role.find_all_givable
    @selected_role_ids = (params[:role_ids] || @givable_roles.map{|r| r.id}).map{|r| r.to_i}
    @dates = ((date_scope - 13)..(date_scope)).map
    @with_subprojects = params[:with_subprojects].nil? ? false : (params[:with_subprojects] == '1')
    projects = @with_subprojects ? @project.self_and_descendants : [@project]
    members = projects.inject([]) {|result, project| result + project.members}.uniq
    @users = members.inject([]) do |result, m|
      if (m.roles.map{|r| r.id} & @selected_role_ids).empty?
        result
      else
        result << m.user         
      end
    end
    if @users.include? User.current
      @users.delete(User.current)
      @users.unshift(User.current)
    end
    @feelings_per_user = {}
    @users.each do |user|
      @feelings_per_user[user] = Feeling.find_by_user_and_date_range(user, @dates)
    end
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
end
