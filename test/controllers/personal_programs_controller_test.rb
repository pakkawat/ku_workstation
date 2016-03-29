require 'test_helper'

class PersonalProgramsControllerTest < ActionController::TestCase
  setup do
    @personal_program = personal_programs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:personal_programs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create personal_program" do
    assert_difference('PersonalProgram.count') do
      post :create, personal_program: { note: @personal_program.note, program_name: @personal_program.program_name }
    end

    assert_redirected_to personal_program_path(assigns(:personal_program))
  end

  test "should show personal_program" do
    get :show, id: @personal_program
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @personal_program
    assert_response :success
  end

  test "should update personal_program" do
    patch :update, id: @personal_program, personal_program: { note: @personal_program.note, program_name: @personal_program.program_name }
    assert_redirected_to personal_program_path(assigns(:personal_program))
  end

  test "should destroy personal_program" do
    assert_difference('PersonalProgram.count', -1) do
      delete :destroy, id: @personal_program
    end

    assert_redirected_to personal_programs_path
  end
end
