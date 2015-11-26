class UsersProgram < ActiveRecord::Base
	belongs_to :ku_user
	belongs_to :program
end
