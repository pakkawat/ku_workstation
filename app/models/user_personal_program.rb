class UserPersonalProgram < ActiveRecord::Base
  belongs_to :ku_user
  belongs_to :personal_program
end
