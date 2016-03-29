class PersonalProgramChef < ActiveRecord::Base
  belongs_to :personal_chef_resource
  belongs_to :personal_program
end
