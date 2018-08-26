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
require File.dirname(__FILE__) + '/../test_helper'

class FeelingTest < ActiveSupport::TestCase
  fixtures :users, :feelings
  test "feelings" do
    clean = lambda do
      assert Feeling.clean!
      assert_equal Feeling.count, 0
    end
    clean[]
    today = Date.today
    user = User.find(1)
    assert Feeling.new
    assert Feeling.new(:at=>today)
    assert Feeling.new(:at=>today, :description=>"aa")
    assert Feeling.new(:at=>today, :description=>"aa", :level=>0)
    assert Feeling.new(:at=>today, :description=>"aa", :level=>0)

    # Valudate of uniqueness
    assert_equal Feeling.new{|f| f.at=today; f.description="aa"; f.level=0; f.user=user}.save, true
    assert_equal Feeling.new{|f| f.at=today; f.description="aa"; f.level=1; f.user=user}.save, false
    assert_equal Feeling.new{|f| f.at=today; f.description="aa"; f.level=2; f.user=user}.save, false
    assert_equal Feeling.count, 1

    # Enum validation
    assert_raises ArgumentError do
      Feeling.new{|f| f.at=today; f.description="aa"; f.level=3; f.user=User.find(1)}.save
    end

    assert_raises ArgumentError do
      Feeling.new{|f| f.at=today; f.description="aa"; f.level=4; f.user=User.find(1)}.save
    end

    # Presence validation
    assert_raises ActiveRecord::RecordInvalid do
      Feeling.new{|f| f.at=today; f.description="aa"; f.level=nil; f.user=User.find(1)}.save!
    end

    clean[]

    # Enum scope test
    assert_equal Feeling.for(user).good?, false
    assert_equal Feeling.good.for(user).good?, true

    assert_equal Feeling.for(user).bad?, false
    assert_equal Feeling.bad.for(user).bad?, true

    assert_equal Feeling.for(user).ordinary?, false
    assert_equal Feeling.ordinary.for(user).ordinary?, true

    assert_equal Feeling.count, 0

    Feeling.ordinary.for(user).save
    assert_equal Feeling.ordinary.count, 1

    clean[]
  end

  test "exclude!" do
    at = 1.years.ago.to_date
    user = User.find(1)
    assert Feeling.clean!
    assert Feeling.new{|f| f.at=at; f.description="aa"; f.level=0; f.user=user}.save
    assert_equal Feeling.new{|f| f.at=at; f.description="aa"; f.level=1; f.user=user}.save, false

    assert Feeling.new{|f| f.at=6.months.ago.to_date; f.description="aa"; f.level=2; f.user=user}.save
    assert Feeling.new{|f| f.at=2.months.ago.to_date; f.description="aa"; f.level=2; f.user=user}.save
    assert_equal Feeling.count, 3

    assert Feeling.exclude_before!((1.years + 1.days).ago.to_date)
    assert_equal Feeling.count, 3
    assert Feeling.exclude_before!(1.years.ago.to_date)
    assert_equal Feeling.count, 2
    assert Feeling.exclude_before!((6.months + 1.days).ago.to_date)
    assert_equal Feeling.count, 2
    assert Feeling.exclude_before!((6.months + 0.days).ago.to_date)
    assert_equal Feeling.count, 1
    assert Feeling.exclude_before!((2.months + 1.days).ago.to_date)
    assert_equal Feeling.count, 1
    assert Feeling.exclude_before!((2.months + 0.days).ago.to_date)
    assert_equal Feeling.count, 0
  end

  test "find_by_user_and_date_range" do
    assert Feeling.clean!
    (0..13).each do |day|
      assert Feeling.new{|f| f.at=(Date.today - day); f.description="aa"; f.level=0; f.user=User.find(1)}.save
    end
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 0)..Date.today).size, 1
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 1)..Date.today).size, 2
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 12)..Date.today).size, 13
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..Date.today).size, 14
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 14)..Date.today).size, 14
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..(Date.today - 1)).size, 13
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..(Date.today - 2)).size, 12
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..(Date.today - 12)).size, 2
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..(Date.today - 13)).size, 1
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 14)..(Date.today - 14)).size, 0
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 100)..(Date.today - 14)).size, 0
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..Date.today)[0].at, (Date.today - 13)
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..Date.today)[1].at, (Date.today - 12)
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..Date.today)[2].at, (Date.today - 11)
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..Date.today)[12].at, (Date.today - 1)
    assert_equal Feeling.find_by_user_and_date_range(User.find(1), (Date.today - 13)..Date.today)[13].at, (Date.today - 0)
    assert_equal Feeling.count, 14
    assert Feeling.clean!
    assert_equal Feeling.count, 0
  end

  test "morale_test" do
    morale = Morale.new(:at => Date.today)
    at = Date.today
    user = User.find(1)
    14.times do |i|
      assert morale << (Feeling.new{|f| f.at=(at); f.description="aa"; f.level=1; f.user=user})
      assert_equal morale <<(Feeling.new{|f| f.at=(at - 1); f.description="aa"; f.level=1; f.user=user}), false
      assert_equal morale <<(Feeling.new{|f| f.at=(at + 1); f.description="aa"; f.level=0; f.user=user}), false
    end
    assert_equal morale.level, 'ordinary'

    morale = Morale.new(:at => at)
    14.times do |i|
      assert morale << (Feeling.new{|f| f.at=(at); f.description="aa"; f.level=1; f.user=user})
    end
    assert_equal morale.ordinary?, false
    morale = Morale.new(:at => at)
    14.times do
      assert morale << (Feeling.new{|f| f.at=(at); f.description="aa"; f.level=0; f.user=user})
    end
    assert_equal morale.level, 'bad'

    morale = Morale.new(:at => Date.today)
    morale << (Feeling.new{|f| f.at=(at); f.description="aa"; f.level=2; f.user=user})
    morale << (Feeling.new{|f| f.at=(at); f.description="aa"; f.level=2; f.user=User.find(2)})
    morale << (Feeling.new{|f| f.at=(at); f.description="aa"; f.level=1; f.user=User.find(3)})

    assert_equal morale.level, 'good'
    morale = Morale.new(:at => at)
    assert_equal morale.level, nil
  end

  test "has_description?" do
    feeling = Feeling.good.for(User.find(1))
    assert_equal feeling.has_description?, false
  end

  test "self.for(date)" do
    assert Feeling.clean!
    assert_equal Feeling.for(User.find(1)).at, Date.today
    Feeling.for(User.find(1)).good!
    assert_equal Feeling.for(User.find(1)).at, Date.today

    assert_equal Feeling.for(User.find(1), (Date.today - 1)).at, (Date.today - 1)
    Feeling.for(User.find(1), (Date.today - 1)).good!
    assert_equal Feeling.for(User.find(1), (Date.today - 1)).at, (Date.today - 1)

    assert_equal Feeling.for(User.find(1), (Date.today - 1.years)).at, (Date.today - 1.years)
    Feeling.for(User.find(1), (Date.today - 1.years)).good!
    assert_equal Feeling.for(User.find(1), (Date.today - 1.years)).at, (Date.today - 1.years)
    assert Feeling.clean!
  end

  test "self.latest" do
    Feeling.clean!
    user = User.find(1)
    assert_nil Feeling.latest(user)
    f2 = Feeling.for(user, Date.today-2)
    f2.good!
    assert_equal Feeling.latest(user), f2
    f1 = Feeling.for(user, Date.today-1)
    f1.good!
    assert_equal Feeling.latest(user), f1
    f0 = Feeling.for(user, Date.today)
    f0.good!
    assert_equal Feeling.latest(user), f0
  end

  test "description" do
    assert Feeling.clean!
    user = User.find(1)
    feeling = Feeling.good.for(user)
    assert_equal feeling.comments.size, 0
    assert_equal feeling.comments_count, 0
    assert_equal feeling.has_comments?, false

    Feeling.good.for(user).save
    feeling = Feeling.good.for(user)
    feeling.add_comment(user, "Test")

    assert_equal feeling.comments_count, 1
    assert_equal feeling.has_comments?, true
    comment = feeling.comments.first
    assert_equal comment.class, Comment
    assert_equal comment.comments, "Test"
    assert_equal comment.author, user

    feeling.add_comment(User.find(2), "Test2")
    feeling = Feeling.for(User.find(1))
    assert_equal feeling.comments.size, 2
    assert_equal feeling.comments_count, 2
    assert_equal feeling.has_comments?, true
    comment = feeling.comments[0]
    assert_equal comment.comments, "Test"
    assert_equal comment.author, user
    comment = feeling.comments[1]
    assert_equal comment.comments, "Test2"
    assert_equal comment.author, User.find(2)
    assert Feeling.clean!
  end
end
