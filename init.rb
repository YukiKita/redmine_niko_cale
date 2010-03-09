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
require 'redmine'

Redmine::Plugin.register :redmine_niko_cale do
  name 'Niko-niko Calender plugin'
  author 'Yuki Kita'
  description 'This is a plugin that makes member\'s feeling visible'
  version '0.8.6'
  requires_redmine :version_or_higher => '0.9.0'

  project_module :niko_cale do
    permission :view_feelings, {:niko_cale => [:index], :feelings=>[:index, :show]}
    permission :edit_feelings, {:feelings=>[:new, :create, :update, :edit, :destroy]},  :require=>:member
    permission :comment_feelings, {:feelings=>:edit_comment}
  end

  menu :project_menu, :niko_cale, {:controller => 'niko_cale', :action => 'index'}, :caption => :label_niko_cale, :param => :project_id
  settings :default=>{"retention_period"=>"0", "editable_period"=>"7", "face_images"=>"original"}, :partial => 'settings/niko_cale_settings'
end
