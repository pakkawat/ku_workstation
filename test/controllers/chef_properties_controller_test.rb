require 'test_helper'

class ChefPropertiesControllerTest < ActionController::TestCase
  setup do
    @chef_property = chef_properties(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:chef_properties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create chef_property" do
    assert_difference('ChefProperty.count') do
      post :create, chef_property: { value: @chef_property.value }
    end

    assert_redirected_to chef_property_path(assigns(:chef_property))
  end

  test "should show chef_property" do
    get :show, id: @chef_property
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @chef_property
    assert_response :success
  end

  test "should update chef_property" do
    patch :update, id: @chef_property, chef_property: { value: @chef_property.value }
    assert_redirected_to chef_property_path(assigns(:chef_property))
  end

  test "should destroy chef_property" do
    assert_difference('ChefProperty.count', -1) do
      delete :destroy, id: @chef_property
    end

    assert_redirected_to chef_properties_path
  end
end
