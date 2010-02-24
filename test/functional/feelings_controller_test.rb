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
require 'feelings_controller'

# Re-raise errors caught by the controller.
class FeelingsController; def rescue_action(e) raise e end; end

class FeelingsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :enabled_modules, :feelings

  def setup
    @controller = FeelingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = User.find(1)
    def @controller.authorize_global
    end
  end

  # Replace this with your real tests.
  def test_show
    @request.session[:user_id] = 1
    get :show, :id=>1, :project_id=>1
    assert_response(:success)
    get :show, :id=>1
    assert_response(:success)
    get :show, :id=>1, :project_id=>0
    assert_response(404)
    get :show, :id=>0, :project_id=>1
    assert_response(404)
  end
end
