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
  def good_image title=l(:label_niko_cale_good)
    image_tag("good.png", {:plugin=>:redmine_niko_cale, :title=>title})
  end
  def ordinary_image title=l(:label_niko_cale_ordinary)
    image_tag("ordinary.png", {:plugin=>:redmine_niko_cale, :title=>title})
  end
  def bad_image title=l(:label_niko_cale_bad)
    image_tag("bad.png", {:plugin=>:redmine_niko_cale, :title=>title})
  end
  def null_image
    image_tag("null.png", {:plugin=>:redmine_niko_cale, :title=>""})
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
end
