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
  def good_image title="", onclick=""
    image_tag("good.png", {:plugin=>:redmine_niko_cale, :title=>title, :onclick=>onclick})
  end
  def ordinary_image title="", onclick=""
    image_tag("ordinary.png", {:plugin=>:redmine_niko_cale, :title=>title, :onclick=>onclick})
  end
  def bad_image title="", onclick=""
    image_tag("bad.png", {:plugin=>:redmine_niko_cale, :title=>title, :onclick=>onclick})
  end
  def null_image
    "<br><br><br>"
  end
  def index_for feeling, with_link=false
    h(format_date(feeling.at)) + " (" + (with_link ? link_to_user(feeling.user) : h(feeling.user.name)) +")"
  end
  def comment_of feeling
    [index_for(feeling), feeling.comment].map{|e| sanitize(e)}.join("<br>")
  end
  def image_for feeling
    if feeling
      image = feeling.good? ? good_image : (feeling.bad? ? bad_image : (feeling.ordinary? ? ordinary_image: null_image))
      feeling.has_comment? ? with_baloon(image, comment_of(feeling)) : image
    else
      null_image
    end
  end
  def link_to_feeling feeling
    link_to image_for(feeling), :controller => "feelings", :action => "show", :id => feeling
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
      color = "blue"
    when 0
      color = "red"
    else
      color = "black"
    end     
    '<font color="' + color + '">' + formatted_date + "</font>"
  end
end
