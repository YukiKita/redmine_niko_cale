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

class FeelingsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :members,
           :member_roles,
           :roles,
           :enabled_modules,
           :feelings

  def setup
    @controller = FeelingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = User.find(1)
    def @controller.authorize_global
    end

    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'niko_cale'
    enabled_module.save

    @request.session[:user_id] = 1
  end

  def test_show
    get :show, id: 1, project_id: 1
    assert_response :success
    assert_template 'show'

    get :show, id: 1
    assert_response :success
    assert_template 'show'

    get :show, id: 1, project_id: 0
    assert_response 404

    get :show, id: 0, project_id: 1
    assert_response 404
  end

  def test_new
    get :new, 'feeling': { 'at': Date.today }
    assert_response :success
    assert_template 'new'

    get :new, 'feeling': { 'at': Date.today }, project_id: 0
    assert_response 404
  end

  def test_create
    post :create, 'feeling': { 'at': Date.today }
    assert_response 404

    post :create, 'feeling': { 'at': Date.today , 'level': '3', 'description': 'aaa' }
    assert_response 404

    post :create, 'feeling': { 'at': Date.today , 'level': '2', 'description': 'aaa' }
    assert_redirected_to controller: :feelings, action: :index, user_id: 1

    post :create, 'feeling': { 'at': Date.today , 'level': '2', 'description': 'aaa' }, project_id: 1
    assert_redirected_to controller: :niko_cale, action: :index, project_id: 'ecookbook'
  end

  def test_delete
    Setting[:plugin_redmine_niko_cale]['retention_period'] = '3'
    f1 = Feeling.for(User.find(1), (3.months.ago.to_date + 1)).good!
    f2 = Feeling.for(User.find(1), (3.months.ago.to_date + 1)).good!
    f3 = Feeling.for(User.find(1), (3.months.ago.to_date - 1)).good!
    f4 = Feeling.for(User.find(1)).good!
    f5 = Feeling.for(User.find(1), (Date.today - 1)).good!

    delete :destroy, id: f4.id
    assert_redirected_to controller: :feelings, action: :index, user_id: 1
    assert_equal Feeling.find(f1.id), f1
    assert_equal Feeling.find(f2.id), f2
    assert_raise(ActiveRecord::RecordNotFound) { Feeling.find(f3.id)}
    assert f1.destroy
    assert f2.destroy

    delete :destroy, id: f5.id, project_id: 1
    assert_redirected_to controller: :niko_cale, action: :index, project_id: 'ecookbook'
  end

  def test_preview
    xhr :put, :update, id: 0
    assert_response 404

    xhr :put, :update, id: 1, 'feeling': { 'level': '3', 'description': 'aaa' }
    assert_response 404

    xhr :put, :update, id: 1, 'feeling': { 'level': '2', 'description': 'aaa' }
    assert_response :success
  end

  def test_index
    get :index, project_id: 0
    assert_response 404

    get :index, user_id: 0
    assert_response 404

    get :index
    assert_response :success
    assert_template 'index'

    get :index, project_id: 1
    assert_response :success
    assert_template 'index'

    get :index, user_id: 1
    assert_response(:success)
    assert_template 'index'

    xhr :get, :index
    assert_response :success
    assert_template 'index'

    xhr :get, :index, project_id: 1
    assert_response :success
    assert_template 'index'

    xhr :get, :index, user_id: 1
    assert_response :success
    assert_template 'index'
  end

  def test_post_comment
    post :edit_comment, id: 0
    assert_response 404

    post :edit_comment, id: 1
    assert_response 404

    post :edit_comment, id: 1, 'comment': { 'comments': '' }
    assert_redirected_to controller: :feelings, action: :index, user_id: 3
    assert_equal Feeling.find(1).comments.size, 0

    post :edit_comment, id: 1, 'comment': { 'comments': 'aaa' }
    assert_redirected_to controller: :feelings, action: :index, user_id: 3
    assert_equal Feeling.find(1).comments.size, 1

    post :edit_comment, id: 1, 'comment': { 'comments': 'aaa' }, project_id: 1
    assert_redirected_to controller: :niko_cale, action: :index, project_id: 'ecookbook'
    assert_equal Feeling.find(1).comments.size, 2
  end

  def test_delete_comment
    feeling = Feeling.find(1)
    feeling.add_comment(User.find(1), 'aaa')
    feeling.add_comment(User.find(1), 'bbb')
    feeling.save
    comment = feeling.comments[0]
    comment2 = feeling.comments[1]

    delete :edit_comment, id: 0
    assert_response 404

    delete :edit_comment, id: 1, comment_id: 0
    assert_response 404

    delete :edit_comment, id: 1, comment_id: comment.id
    assert_redirected_to controller: :feelings, action: :index, user_id: 3

    delete :edit_comment, id: 1, comment_id: comment2.id, project_id: 1
    assert_redirected_to controller: :niko_cale, action: :index, project_id: 'ecookbook'
  end

  def test_preview_comment
    xhr :post, :edit_comment, id: 0
    assert_response 404

    xhr :post, :edit_comment, id: 1
    assert_response 404

    xhr :post, :edit_comment, id: 1, 'comment': { 'comments': 'aa' }
    assert_response :success
  end
end
