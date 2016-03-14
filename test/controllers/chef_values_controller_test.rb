require 'test_helper'

class ChefValuesControllerTest < ActionController::TestCase
  setup do
    @chef_value = chef_values(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:chef_values)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create chef_value" do
    assert_difference('ChefValue.count') do
      post :create, chef_value: { chef_attribute_id: @chef_value.chef_attribute_id, ku_user_id: @chef_value.ku_user_id, value: @chef_value.value }
    end

    assert_redirected_to chef_value_path(assigns(:chef_value))
  end

  test "should show chef_value" do
    get :show, id: @chef_value
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @chef_value
    assert_response :success
  end

  test "should update chef_value" do
    patch :update, id: @chef_value, chef_value: { chef_attribute_id: @chef_value.chef_attribute_id, ku_user_id: @chef_value.ku_user_id, value: @chef_value.value }
    assert_redirected_to chef_value_path(assigns(:chef_value))
  end

  test "should destroy chef_value" do
    assert_difference('ChefValue.count', -1) do
      delete :destroy, id: @chef_value
    end

    assert_redirected_to chef_values_path
  end
end
