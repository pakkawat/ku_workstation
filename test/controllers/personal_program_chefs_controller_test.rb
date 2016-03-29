require 'test_helper'

class PersonalProgramChefsControllerTest < ActionController::TestCase
  setup do
    @personal_program_chef = personal_program_chefs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:personal_program_chefs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create personal_program_chef" do
    assert_difference('PersonalProgramChef.count') do
      post :create, personal_program_chef: { personal_chef_resource_id: @personal_program_chef.personal_chef_resource_id, personal_program_id: @personal_program_chef.personal_program_id }
    end

    assert_redirected_to personal_program_chef_path(assigns(:personal_program_chef))
  end

  test "should show personal_program_chef" do
    get :show, id: @personal_program_chef
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @personal_program_chef
    assert_response :success
  end

  test "should update personal_program_chef" do
    patch :update, id: @personal_program_chef, personal_program_chef: { personal_chef_resource_id: @personal_program_chef.personal_chef_resource_id, personal_program_id: @personal_program_chef.personal_program_id }
    assert_redirected_to personal_program_chef_path(assigns(:personal_program_chef))
  end

  test "should destroy personal_program_chef" do
    assert_difference('PersonalProgramChef.count', -1) do
      delete :destroy, id: @personal_program_chef
    end

    assert_redirected_to personal_program_chefs_path
  end
end
