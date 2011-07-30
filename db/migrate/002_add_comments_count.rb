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
class AddCommentsCount < ActiveRecord::Migration
  def self.up
    rename_column(:feelings, :comment, :description)
    add_column(:feelings, "comments_count", :integer, :default => 0,  :null => false)
  end

  def self.down
    remove_column(:feelings, "comments_count")
    rename_column(:feelings, :description, :comment)
  end
end
