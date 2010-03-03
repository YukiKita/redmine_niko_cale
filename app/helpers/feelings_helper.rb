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
      return title
    elsif (project = option[:project])
      title = project.name
    elsif (user = option[:user])
      title = user.name
    else
      title = l(:label_niko_cale_all_users)
    end
    "#{l(:label_niko_cale_feeling_list)} (#{title})"
  end
  def link_to_feeling_list option={}
    if (project = option[:project])
      link_to(h(feeling_list(option)), {:controller=>:feelings, :action=>:index, :project_id=>project})
    elsif (user = option[:user])
      link_to(h(feeling_list(option)), {:controller=>:feelings, :action=>:index, :user_id=>user})
    else
      link_to(h(feeling_list(option)), {:controller=>:feelings, :action=>:index})
    end
  end
  def atom_conditions option={}
    conditions = {:key => User.current.rss_key}
    if (project = option[:project])
      conditions[:project_id] = project.id
    elsif (user = option[:user])
      conditions[:user_id] = user.id
    else
    end
    conditions
  end
  def good_image title="", onclick="", style=""
    image_tag("good.png", {:plugin=>:redmine_niko_cale, :title=>title, :onclick=>onclick, :style=>style})
  end
  def ordinary_image title="", onclick="", style=""
    image_tag("ordinary.png", {:plugin=>:redmine_niko_cale, :title=>title, :onclick=>onclick, :style=>style})
  end
  def bad_image title="", onclick="", style=""
    image_tag("bad.png", {:plugin=>:redmine_niko_cale, :title=>title, :onclick=>onclick, :style=>style})
  end
  def null_image
    "<br><br><br>"
  end
  def add_image
    image_tag("add.png", {:plugin=>:redmine_niko_cale, :title=>l(:button_add)})
  end
  def edit_image
    image_tag("edit.png") + l(:button_update)
  end
  def delete_image
    image_tag("delete.png") + l(:button_delete)
  end
  def previous_image title="", onclick=""
    image_tag("previous.png", {:plugin=>:redmine_niko_cale, :onclick=>onclick, :title=>title, :style=>"cursor: pointer;"})
  end
  def next_image title="", onclick=""
    image_tag("next.png", {:plugin=>:redmine_niko_cale, :onclick=>onclick, :title=>title, :style=>"cursor: pointer;"})
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
      image = feeling.good? ? good_image : (feeling.bad? ? bad_image : (feeling.ordinary? ? ordinary_image: null_image))
      feeling.has_description? ? with_baloon(image, description_of(feeling)) : image
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
    d = date.to_s.split("-")
    formatted_date = d[0] + "<br>" + d[1] + "/" + d[2]
    color = ""
    case date.wday
    when 6  
      '<font color="blue">' + formatted_date + "</font>"
    when 0
      color = '<font color="red">' + formatted_date + "</font>"
    else
      '<font color="black">' + formatted_date + "</font>"
    end     
  end
  def editable?(feeling)
    editable_period = Setting.plugin_redmine_niko_cale["editable_period"].to_i
    if editable_period == 0
      (User.current == feeling.user)
    else
      delta = (Date.today - feeling.at)
      ((0 <= delta) && (delta < editable_period)) && (User.current == feeling.user)
    end
  end
end
