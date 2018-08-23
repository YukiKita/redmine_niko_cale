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
require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NikoCaleControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :feelings

  # Replace this with your real tests.
  def setup
    @controller = NikoCaleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = User.find(1)
    def @controller.authorize_global
    end

    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'niko_cale'
    enabled_module.save
  end

  def test_no_routes_match_when_project_id_blank
    assert_raises(ActionController::UrlGenerationError) do
      get '/niko_cale'
    end
  end

  def test_index
    get :index, project_id: 0
    assert_response 404
    get :index, project_id: 1
    assert_response :success

    assert_template 'index'
    xhr :get, :index, project_id: 1
    assert_response :success
  end
end
