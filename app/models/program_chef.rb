class ProgramChef < ActiveRecord::Base
  belongs_to :program
  belongs_to :chef_resource
end
