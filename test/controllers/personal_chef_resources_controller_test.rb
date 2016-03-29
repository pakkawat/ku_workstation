require 'test_helper'

class PersonalChefResourcesControllerTest < ActionController::TestCase
  setup do
    @personal_chef_resource = personal_chef_resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:personal_chef_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create personal_chef_resource" do
    assert_difference('PersonalChefResource.count') do
      post :create, personal_chef_resource: { priority: @personal_chef_resource.priority, resource_type: @personal_chef_resource.resource_type }
    end

    assert_redirected_to personal_chef_resource_path(assigns(:personal_chef_resource))
  end

  test "should show personal_chef_resource" do
    get :show, id: @personal_chef_resource
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @personal_chef_resource
    assert_response :success
  end

  test "should update personal_chef_resource" do
    patch :update, id: @personal_chef_resource, personal_chef_resource: { priority: @personal_chef_resource.priority, resource_type: @personal_chef_resource.resource_type }
    assert_redirected_to personal_chef_resource_path(assigns(:personal_chef_resource))
  end

  test "should destroy personal_chef_resource" do
    assert_difference('PersonalChefResource.count', -1) do
      delete :destroy, id: @personal_chef_resource
    end

    assert_redirected_to personal_chef_resources_path
  end
end
