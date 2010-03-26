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
    title = ''
    if option[:title]
      return option[:title] 
    elsif option[:project]
      title = option[:project].name
    elsif option[:user]
      title = option[:user].name
    else
      title = l(:label_niko_cale_all_users)
    end
    "#{l(:label_niko_cale_feeling_list)} (#{title})"
  end
  def link_to_feeling_list option={}
    if option[:project]
      link_to(h(feeling_list(option)), {:controller=>:feelings, :action=>:index, :project_id=>option[:project]})
    elsif option[:user]
      link_to(h(feeling_list(option)), {:controller=>:feelings, :action=>:index, :user_id=>option[:user]})
    else
      link_to(h(feeling_list(option)), {:controller=>:feelings, :action=>:index})
    end
  end
  def atom_conditions option={}
    conditions = {:key => User.current.rss_key}
    if option[:project]
      conditions[:project_id] = option[:project].identifier
    elsif option[:user]
      conditions[:user_id] = option[:user].id
    else
    end
    conditions
  end
  def face_image image, title="", onclick="", style=""
    my_image 'faces/' + (Setting.plugin_redmine_niko_cale['face_images'] || 'original') + '/' + image + '.png', title, onclick, style
  end
  def my_image path, title="", onclick="", style=""
    image_tag(path, {:plugin=>:redmine_niko_cale, :title=>title, :onclick=>onclick, :style=>style})
  end
  def null_image
    ''
  end
  def add_image
    my_image 'add.png', l(:button_add)
  end
  def version_image
    image_tag("package.png")
  end
  def previous_image title="", onclick=""
    my_image 'previous.png', title, onclick, 'cursor: pointer;'
  end
  def next_image title="", onclick=""
    my_image 'next.png', title, onclick, 'cursor: pointer;'
  end
  def index_for feeling, with_link=false
    h(format_date(feeling.at)) + " (" + (with_link ? link_to_user(feeling.user) : h(feeling.user.name)) +")"
  end
  def description_of feeling
    strip_tags(index_for(feeling) + "\n" +  feeling.description).gsub(/\r\n|\r|\n/, "<br />").gsub(/["']/,'') +
    (feeling.has_comments? ? "<br>(#{l(:label_x_comments, :count => feeling.comments_count)})"  : "")
  end
  def image_for feeling
    if feeling
      image = feeling.good? ? face_image('good') : (feeling.bad? ? face_image('bad') : (feeling.ordinary? ? face_image('ordinary'): null_image))
      (feeling.has_description? || feeling.has_comments?) ? with_baloon(image, description_of(feeling)) : image
    else
      null_image
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
  def format_date_with_color date
    formatted_date = date.day.to_s
    color = ""
    case date.wday
    when 6  
      '<font color="blue">' + formatted_date + "</font>"
    when 0
      color = '<font color="red">' + formatted_date + "</font>"
    else
      formatted_date
    end     
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
