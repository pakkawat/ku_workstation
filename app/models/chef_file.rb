class ChefFile < ActiveRecord::Base
  belongs_to :personal_chef_resource
  belongs_to :chef_resource
end
