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
module FeelingsHelper
  def transparent_png_patch_include_tag
    '<!--[if lt IE 7]>' + javascript_include_tag("unitpngfix.js", :plugin => "redmine_niko_cale") +  '<![endif]--> '
  end
  def feeling_list option={}
    title = option[:title]
    if title
      title
    else
      project = option[:project]
      user = option[:user]
      if project
        title = project.name
      elsif user
        title = user.name
      else
        title = l(:label_niko_cale_all_users)
      end
      "#{l(:label_niko_cale_feeling_list)} (#{title})"
    end
  end
  def link_to_feeling_list option={}
    url = {:controller=>:feelings, :action=>:index}
    project = option[:project]
    user = option[:user] 
    if project
      url[:project_id] = project
    elsif user
      url[:user_id] = user
    end
    link_to(h(feeling_list(option)), url)
  end
  def atom_conditions option={}
    conditions = {:key => User.current.rss_key}
    project = option[:project]
    user = option[:user] 
    if project
      conditions[:project_id] = project.identifier
    elsif user
      conditions[:user_id] = user.id
    end
    conditions
  end
  def face_image image, title="", onclick="", style="", name=(Setting.plugin_redmine_niko_cale['face_images'] || 'original')
    path = 'faces/' + name + '/' + image + '.png'
    path = path.gsub(/\.png/, '.gif') unless File.exist?(Rails.root.to_s + '/public/plugin_assets/redmine_niko_cale/images/' + path)
    my_image path, title, onclick, style
  end
  def my_image path, title="", onclick="", style=""
    image_tag(path, {:plugin=>:redmine_niko_cale, :title=>title, :onclick=>onclick, :style=>style})
  end
  def add_image
    my_image 'add.png', l(:button_add)
  end
  def version_image
    image_tag("package.png")
  end
  def previous_image title="", onclick=""
    my_image 'previous.png', title, onclick, 'cursor: pointer;margin-right: 48px'
  end
  def next_image title="", onclick=""
    my_image 'next.png', title, onclick, 'cursor: pointer;'
  end
  def index_for feeling, with_link=false
    user = feeling.user
    h(format_date(feeling.at)) + " (" + (with_link ? link_to_user(user) : h(user.name)) +")"
  end
  def description_of feeling
    strip_tags(index_for(feeling) + "\n" +  feeling.description).gsub(/\r\n|\r|\n/, "<br />").gsub(/["']/,'') +
    (feeling.has_comments? ? "<br>(#{l(:label_x_comments, :count => feeling.comments_count)})"  : "")
  end
  def image_for feeling
    if feeling
      image = feeling.good? ? face_image('good') : (feeling.bad? ? face_image('bad') : (feeling.ordinary? ? face_image('ordinary'): ''))
      (feeling.has_description? || feeling.has_comments?) ? with_baloon(image, description_of(feeling)) : image
    else
      ''
    end
  end
  def link_to_feeling feeling, project_id=nil
    link_to image_for(feeling), :controller => "feelings", :action => "show", :id => feeling, :project_id=>project_id
  end
  def with_baloon object, message=""
    '<span onmouseover="showToolTip(event,\'' + message + '\');return false" onmouseout="hideToolTip()">' + object + '</span>'
  end
  def format_date date
    date.to_s.gsub(/-/, "/")
  end
  def link_to_date date, project
    formatted_date = date.day.to_s
    style = nil
    case date.wday
    when 6  
      style = 'color:blue'
    when 0
      style = 'color:red'
    else
      style = nil
    end     
    link_to(formatted_date, {:controller=>:projects, :action=>:activity, :id=>project, :from=>date}, {:style=>style})
  end
  def editable?(feeling)
    editable_period = Setting.plugin_redmine_niko_cale["editable_period"].to_i
    feeling_owner_is_current_user = (User.current == feeling.user)
    if (editable_period == 0)
      feeling_owner_is_current_user
    else
      delta = (Date.today - feeling.at)
      (0 <= delta) && (delta < editable_period) && feeling_owner_is_current_user
    end
  end
  def current_user_allowed_to? controller, action
    User.current.allowed_to?({:controller =>controller, :action =>action}, nil, :global => true)
  end
  def link_to_issues_list title, project_id=nil, user_id=nil
    link_to title, :controller => 'issues', :action => 'index', :set_filter => 1,
    :assigned_to_id => user_id, :sort => 'priority:desc,updated_on:desc', :project_id=>project_id
  end
end
