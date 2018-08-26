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
class Feeling < ActiveRecord::Base
  belongs_to :user
  acts_as_event :url => Proc.new {|feeling| {:controller => 'feelings', :action => 'show', :id => feeling.id}}, :datetime=>:at
  has_many :comments, lambda { order(:created_on) }, as: :commented, dependent: :delete_all
  enum level: { bad: 0, ordinary: 1, good: 2 }
  validates :level, presence: true
  validates :at, :uniqueness => {:scope => :user_id}

  def has_description?
    return description.present?
  end

  def has_comments?
    self.comments_count > 0
  end

  # for Atom feed
  def project
    result = "#{self.user.name}@#{self.at}"
    # added dummy method because feeling is not related to any project
    def result.wiki; nil ;end
    result
  end

  # for Atom feed
  def title
    "#{l(("label_niko_cale_" + lebel).to_sym)}"
  end

  # for Atom feed
  def author
    self.user
  end

  def add_comment user, comment
    new_comment = Comment.new(:comments=>comment, :author=>user)
    (self.comments << new_comment) && new_comment
  end

  def self.for(user, date = Date.today)
    condition = Feeling.where(user: user).where(at: date).first
    condition || Feeling.new({ at: date, user: user })
  end

  def self.clean!
    Feeling.destroy_all
  end

  def self.exclude_before! date
    Feeling.destroy_all(["at <= ?", date])
  end

  def self.find_by_user_and_date_range user, date_range
    Feeling.where(user_id: user)
           .where(at: date_range.first..date_range.last)
           .order('at ASC')
  end

  def self.latest user
    Feeling.where(user_id: user).order('at DESC').first
  end

  def level_name(level_value)
    Feeling.levels.key(level_value)
  end
end
