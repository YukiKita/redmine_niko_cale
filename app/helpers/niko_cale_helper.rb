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
module NikoCaleHelper
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
  def format_date date
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
  def gray
    "#C4CACC"
  end
  def light_blue
    '"#CAE5F1"'
  end
  def blue
    '"#87CEFA"'
  end
  def light_yellow
    "#F4FAA0"
  end
  def light_gray
    "#DCDCDC"
  end
  def with_baloon object, message=""
    '<span onmouseover="showToolTip(event,\'' + message + '\');return false" onmouseout="hideToolTip()">' + object + '</span>'
  end
  def comment_of feeling
    user = feeling.user
    name = user ? user.name : l(:label_niko_cale_morale)
    [feeling.at.to_s.gsub(/-/, "/"), name, feeling.comment].join("<br>")
  end
  def image_for feeling
    if feeling
      image = feeling.good? ? good_image : (feeling.bad? ? bad_image : (feeling.ordinary? ? ordinary_image: null_image))
      feeling.has_comment? ? with_baloon(image, comment_of(feeling)) : image
    else
      null_image
    end
  end
end
