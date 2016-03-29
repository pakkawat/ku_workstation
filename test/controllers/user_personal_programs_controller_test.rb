require 'test_helper'

class UserPersonalProgramsControllerTest < ActionController::TestCase
  setup do
    @user_personal_program = user_personal_programs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_personal_programs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_personal_program" do
    assert_difference('UserPersonalProgram.count') do
      post :create, user_personal_program: { ku_user_id: @user_personal_program.ku_user_id, personal_program_id: @user_personal_program.personal_program_id, status: @user_personal_program.status }
    end

    assert_redirected_to user_personal_program_path(assigns(:user_personal_program))
  end

  test "should show user_personal_program" do
    get :show, id: @user_personal_program
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_personal_program
    assert_response :success
  end

  test "should update user_personal_program" do
    patch :update, id: @user_personal_program, user_personal_program: { ku_user_id: @user_personal_program.ku_user_id, personal_program_id: @user_personal_program.personal_program_id, status: @user_personal_program.status }
    assert_redirected_to user_personal_program_path(assigns(:user_personal_program))
  end

  test "should destroy user_personal_program" do
    assert_difference('UserPersonalProgram.count', -1) do
      delete :destroy, id: @user_personal_program
    end

    assert_redirected_to user_personal_programs_path
  end
end
