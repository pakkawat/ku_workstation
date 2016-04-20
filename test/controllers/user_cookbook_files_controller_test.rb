require 'test_helper'

class UserCookbookFilesControllerTest < ActionController::TestCase
  setup do
    @user_cookbook_file = user_cookbook_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_cookbook_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_cookbook_file" do
    assert_difference('UserCookbookFile.count') do
      post :create, user_cookbook_file: {  }
    end

    assert_redirected_to user_cookbook_file_path(assigns(:user_cookbook_file))
  end

  test "should show user_cookbook_file" do
    get :show, id: @user_cookbook_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_cookbook_file
    assert_response :success
  end

  test "should update user_cookbook_file" do
    patch :update, id: @user_cookbook_file, user_cookbook_file: {  }
    assert_redirected_to user_cookbook_file_path(assigns(:user_cookbook_file))
  end

  test "should destroy user_cookbook_file" do
    assert_difference('UserCookbookFile.count', -1) do
      delete :destroy, id: @user_cookbook_file
    end

    assert_redirected_to user_cookbook_files_path
  end
end
