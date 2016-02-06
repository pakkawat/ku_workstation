require 'test_helper'

class ChefResourcesControllerTest < ActionController::TestCase
  setup do
    @chef_resource = chef_resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:chef_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create chef_resource" do
    assert_difference('ChefResource.count') do
      post :create, chef_resource: { resource_type: @chef_resource.resource_type }
    end

    assert_redirected_to chef_resource_path(assigns(:chef_resource))
  end

  test "should show chef_resource" do
    get :show, id: @chef_resource
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @chef_resource
    assert_response :success
  end

  test "should update chef_resource" do
    patch :update, id: @chef_resource, chef_resource: { resource_type: @chef_resource.resource_type }
    assert_redirected_to chef_resource_path(assigns(:chef_resource))
  end

  test "should destroy chef_resource" do
    assert_difference('ChefResource.count', -1) do
      delete :destroy, id: @chef_resource
    end

    assert_redirected_to chef_resources_path
  end
end
