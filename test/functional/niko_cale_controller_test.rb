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
require 'niko_cale_controller'

# Re-raise errors caught by the controller.
class NikoCaleController; def rescue_action(e) raise e end; end

class NikoCaleControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    @controller = NikoCaleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = User.find(1)
    def @controller.authorize_global
    end
  end
  def test_index
    get :index
    assert_response(404)
    get :index, :project_id=>0
    assert_response(404)
    get :index, :project_id=>1
    assert_response(:success)
    assert_template "index"
  end
  def test_show
    [:put, :get, :delete, :post].each do |m|
      __send__ m, :show, {:project_id=>1}
      assert_redirected_to(:controller=>:niko_cale, :action=>:index, :project_id=>1)
    end
  end
end
