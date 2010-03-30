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
      assert_equal Feeling.count, 0
    end
    clean[]
    assert Feeling.new
    assert Feeling.new(:at=>Date.today)
    assert Feeling.new(:at=>Date.today, :description=>"aa")
    assert Feeling.new(:at=>Date.today, :description=>"aa", :level=>0)
    assert Feeling.new(:at=>Date.today, :description=>"aa", :level=>0)
    assert Feeling.new{|f| f.at=Date.today; f.description="aa"; f.level=0; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=Date.today; f.description="aa"; f.level=1; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=Date.today; f.description="aa"; f.level=2; f.user=User.find(1)}.save
    assert_equal Feeling.count, 3
    assert_equal Feeling.new{|f| f.at=Date.today; f.description="aa"; f.level=3; f.user=User.find(1)}.save, false
    assert_equal Feeling.new{|f| f.at=Date.today; f.description="aa"; f.level=4; f.user=User.find(1)}.save, false
    assert_equal Feeling.new{|f| f.at=Date.today; f.description="aa"; f.user=User.find(1)}.save, false
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
    assert_equal Feeling.count, 3
    clean[]
  end
  test "exclude!" do
    assert Feeling.clean!
    assert Feeling.new{|f| f.at=1.years.ago.to_date; f.description="aa"; f.level=0; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=1.years.ago.to_date; f.description="aa"; f.level=1; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=1.years.ago.to_date; f.description="aa"; f.level=2; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=6.months.ago.to_date; f.description="aa"; f.level=2; f.user=User.find(1)}.save
    assert Feeling.new{|f| f.at=2.months.ago.to_date; f.description="aa"; f.level=2; f.user=User.find(1)}.save
    assert_equal Feeling.count, 5
    assert Feeling.exclude_before!((1.years + 1.days).ago.to_date)
    assert_equal Feeling.count, 5
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
    14.times do |i|
      assert morale << (Feeling.new{|f| f.at=(Date.today); f.description="aa"; f.level=2; f.user=User.find(1)})
      assert_equal morale <<(Feeling.new{|f| f.at=(Date.today - 1); f.description="aa"; f.level=0; f.user=User.find(1)}), false
      assert_equal morale <<(Feeling.new{|f| f.at=(Date.today + 1); f.description="aa"; f.level=0; f.user=User.find(1)}), false
    end
    assert morale.good?
    morale = Morale.new(:at => Date.today)
    14.times do |i|
      assert morale << (Feeling.new{|f| f.at=(Date.today); f.description="aa"; f.level=1; f.user=User.find(1)})
    end
    assert morale.ordinary?
    morale = Morale.new(:at => Date.today)
    14.times do
      assert morale << (Feeling.new{|f| f.at=(Date.today); f.description="aa"; f.level=0; f.user=User.find(1)})
    end
    assert morale.bad?
    morale = Morale.new(:at => Date.today)
    assert morale << (Feeling.new{|f| f.at=(Date.today); f.description="aa"; f.level=0; f.user=User.find(1)})
    assert morale << (Feeling.new{|f| f.at=(Date.today); f.description="aa"; f.level=1; f.user=User.find(1)})
    assert morale << (Feeling.new{|f| f.at=(Date.today); f.description="aa"; f.level=2; f.user=User.find(1)})
    assert morale.ordinary?
    morale = Morale.new(:at => Date.today)
    assert_nil morale.level
    assert_equal morale.good?, false
    assert_equal morale.ordinary?, false
    assert_equal morale.bad?, false
  end
  test "has_description?" do
    feeling = Feeling.for(User.find(1))
    assert !feeling.has_description?
    assert !feeling.good("").has_description?
    assert !feeling.good(nil).has_description?
    assert feeling.good(" ").has_description?
    assert feeling.good("1     2").has_description?
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
  test "description" do
    assert Feeling.clean!
    feeling = Feeling.for(User.find(1)).good!
    assert_equal feeling.comments.size, 0
    assert_equal feeling.comments_count, 0
    assert_equal feeling.has_comments?, false
    feeling.add_comment(User.find(2), "Test")
    feeling = Feeling.for(User.find(1))
    assert_equal feeling.comments_count, 1
    assert_equal feeling.has_comments?, true
    comment = feeling.comments.first
    assert_equal comment.class, Comment
    assert_equal comment.comments, "Test"
    assert_equal comment.author, User.find(2)

    feeling.add_comment(User.find(2), "Test2")
    feeling = Feeling.for(User.find(1))
    assert_equal feeling.comments.size, 2
    assert_equal feeling.comments_count, 2
    assert_equal feeling.has_comments?, true
    comment = feeling.comments[0]
    assert_equal comment.comments, "Test"
    assert_equal comment.author, User.find(2)
    comment = feeling.comments[1]
    assert_equal comment.comments, "Test2"
    assert_equal comment.author, User.find(2)
    assert Feeling.clean!
  end
end
