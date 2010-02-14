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
  test "feelings" do
    clean = lambda do
      assert Feeling.clean!
      assert Feeling.find(:all).empty?
    end
    clean[]
    assert Feeling.new
    assert Feeling.new(:at=>Date.today)
    assert Feeling.new(:at=>Date.today, :comment=>"aa")
    assert Feeling.new(:at=>Date.today, :comment=>"aa", :level=>0)
    assert Feeling.new(:at=>Date.today, :comment=>"aa", :level=>0)
    assert Feeling.new{|f| f.at=Date.today; f.comment="aa"; f.level=0; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=Date.today; f.comment="aa"; f.level=1; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=Date.today; f.comment="aa"; f.level=2; f.user=User.find(1)}.save
    assert_equal Feeling.find(:all).size, 3
    assert_equal Feeling.new{|f| f.at=Date.today; f.comment="aa"; f.level=3; f.user=User.find(1)}.save, false
    assert_equal Feeling.new{|f| f.at=Date.today; f.comment="aa"; f.level=4; f.user=User.find(1)}.save, false
    assert_equal Feeling.new{|f| f.at=Date.today; f.comment="aa"; f.user=User.find(1)}.save, false
    clean[]
    assert Feeling.for(User.find(1)).good!.good?
    assert_equal Feeling.for(User.find(1)).bad?, false
    assert Feeling.for(User.find(1)).bad!.bad?
    assert_equal Feeling.for(User.find(1)).ordinary?, false
    assert Feeling.for(User.find(1)).ordinary!.ordinary?
    assert Feeling.for(User.find(2)).bad!.bad?
    assert_equal Feeling.for(User.find(2)).good?, false
    assert_equal Feeling.for(User.find(2)).ordinary?, false
    assert Feeling.for(User.find(3)).ordinary!.ordinary?
    assert_equal Feeling.for(User.find(3)).good?, false
    assert_equal Feeling.for(User.find(3)).bad?, false
    assert_equal Feeling.find(:all).size, 3
    clean[]
  end
  test "exclude!" do
    assert Feeling.clean!
    assert Feeling.new{|f| f.at=1.years.ago.to_date; f.comment="aa"; f.level=0; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=1.years.ago.to_date; f.comment="aa"; f.level=1; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=1.years.ago.to_date; f.comment="aa"; f.level=2; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=6.months.ago.to_date; f.comment="aa"; f.level=2; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=2.months.ago.to_date; f.comment="aa"; f.level=2; f.user=User.find(1)}.save
    assert_equal Feeling.find(:all).size, 5
    assert Feeling.exclude_before!((1.years + 1.days).ago.to_date)
    assert_equal Feeling.find(:all).size, 5
    assert Feeling.exclude_before!(1.years.ago.to_date)
    assert_equal Feeling.find(:all).size, 2
    assert Feeling.exclude_before!((6.months + 1.days).ago.to_date)
    assert_equal Feeling.find(:all).size, 2
    assert Feeling.exclude_before!((6.months + 0.days).ago.to_date)
    assert_equal Feeling.find(:all).size, 1
    assert Feeling.exclude_before!((2.months + 1.days).ago.to_date)
    assert_equal Feeling.find(:all).size, 1
    assert Feeling.exclude_before!((2.months + 0.days).ago.to_date)
    assert_equal Feeling.find(:all).size, 0
  end
  test "find_by_user_and_date_range" do
    assert Feeling.clean!
    (0..13).each do |day|
      assert Feeling.new{|f| f.at=(Date.today - day); f.comment="aa"; f.level=0; f.user=User.find(1)}.save
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
    assert_equal Feeling.find(:all).size, 14
    assert Feeling.clean!
    assert_equal Feeling.find(:all).size, 0
  end
  test "mood_test" do
    mood = Mood.new(:at => Date.today)
    14.times do |i|
      assert mood.add(Feeling.new{|f| f.at=(Date.today); f.comment="aa"; f.level=2; f.user=User.find(1)})
      assert_equal mood.add(Feeling.new{|f| f.at=(Date.today - 1); f.comment="aa"; f.level=0; f.user=User.find(1)}), false
      assert_equal mood.add(Feeling.new{|f| f.at=(Date.today + 1); f.comment="aa"; f.level=0; f.user=User.find(1)}), false
    end
    assert mood.good?
    mood = Mood.new(:at => Date.today)
    14.times do |i|
      assert mood.add(Feeling.new{|f| f.at=(Date.today); f.comment="aa"; f.level=1; f.user=User.find(1)})
    end
    assert mood.ordinary?
    mood = Mood.new(:at => Date.today)
    14.times do
      assert mood.add(Feeling.new{|f| f.at=(Date.today); f.comment="aa"; f.level=0; f.user=User.find(1)})
    end
    assert mood.bad?
    mood = Mood.new(:at => Date.today)
    assert mood.add(Feeling.new{|f| f.at=(Date.today); f.comment="aa"; f.level=0; f.user=User.find(1)})
    assert mood.add(Feeling.new{|f| f.at=(Date.today); f.comment="aa"; f.level=1; f.user=User.find(1)})
    assert mood.add(Feeling.new{|f| f.at=(Date.today); f.comment="aa"; f.level=2; f.user=User.find(1)})
    assert mood.ordinary?
  end
end
