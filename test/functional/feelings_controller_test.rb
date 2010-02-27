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
  def test_show
    @request.session[:user_id] = 1
    get :show, :id=>1, :project_id=>1
    assert_response(:success)
    assert_template "show"
    get :show, :id=>1
    assert_response(:success)
    assert_template "show"
    get :show, :id=>1, :project_id=>0
    assert_response(404)
    get :show, :id=>0, :project_id=>1
    assert_response(404)
  end
  def test_edit
    @request.session[:user_id] = 1
    get :edit, :date=>Date.today
    assert_response(:success)
    assert_template "edit"
    get :edit, :date=>Date.today, :project_id=>0
    assert_response(404)
  end
  def test_put
    @request.session[:user_id] = 1
    put :edit, :date=>Date.today
    assert_response(404)
    put :edit, :date=>Date.today, :level=>3, :comment=>"aaa"
    assert_response(404)
    put :edit, :date=>Date.today, :level=>2, :comment=>"aaa"
    assert_redirected_to(:controller=>:feelings, :action=>:index, :user_id=>1)
    put :edit, :date=>Date.today, :level=>2, :comment=>"aaa", :project_id=>1
    assert_redirected_to(:controller=>:niko_cale, :action=>:index, :project_id=>1)
  end
  def test_delete
    @request.session[:user_id] = 1
    Setting[:plugin_redmine_niko_cale]["retention_period"] = "3"
    f1 = Feeling.for(User.find(1), (3.months.ago.to_date + 1)).good!
    f2 = Feeling.for(User.find(1), (3.months.ago.to_date + 1)).good!
    f3 = Feeling.for(User.find(1), (3.months.ago.to_date - 1)).good!
    delete :edit, :date=>Date.today
    assert_redirected_to(:controller=>:feelings, :action=>:index, :user_id=>1)
    assert_equal Feeling.find(f1.id), f1
    assert_equal Feeling.find(f2.id), f2
    assert_raise(ActiveRecord::RecordNotFound) { Feeling.find(f3.id)}
    assert f1.destroy
    assert f2.destroy
    delete :edit, :date=>Date.today, :project_id=>1
    assert_redirected_to(:controller=>:niko_cale, :action=>:index, :project_id=>1)
  end
  def test_preview
    @request.session[:user_id] = 1
    xhr :post, :edit, :date=>Date.today + 1
    assert_response(404)
    xhr :post, :edit, :date=>Date.today - 7
    assert_response(404)
    xhr :post, :edit, :date=>Date.today, :level=>3, :comment=>"aa"
    assert_response(404)
    xhr :post, :edit, :date=>Date.today, :level=>2, :comment=>"aa"
    assert_response(:success)
  end
  def test_index
    @request.session[:user_id] = 1
    get :index, :project_id=>0 
    assert_response(404)
    get :index, :user_id=>0
    assert_response(404)
    get :index
    assert_response(:success)
    assert_template "index"
    get :index, :project_id=>1 
    assert_response(:success)
    assert_template "index"
    get :index, :user_id=>1 
    assert_response(:success)
    assert_template "index"
    xhr :get, :index
    assert_response(:success)
    assert_template "index"
    xhr :get, :index, :project_id=>1 
    assert_response(:success)
    assert_template "index"
    xhr :get, :index, :user_id=>1 
    assert_response(:success)
    assert_template "index"
  end
end
