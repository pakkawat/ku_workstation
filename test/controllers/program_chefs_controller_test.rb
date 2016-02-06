require 'test_helper'

class ProgramChefsControllerTest < ActionController::TestCase
  setup do
    @program_chef = program_chefs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:program_chefs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create program_chef" do
    assert_difference('ProgramChef.count') do
      post :create, program_chef: {  }
    end

    assert_redirected_to program_chef_path(assigns(:program_chef))
  end

  test "should show program_chef" do
    get :show, id: @program_chef
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @program_chef
    assert_response :success
  end

  test "should update program_chef" do
    patch :update, id: @program_chef, program_chef: {  }
    assert_redirected_to program_chef_path(assigns(:program_chef))
  end

  test "should destroy program_chef" do
    assert_difference('ProgramChef.count', -1) do
      delete :destroy, id: @program_chef
    end

    assert_redirected_to program_chefs_path
  end
end
