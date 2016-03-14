class ChefValue < ActiveRecord::Base
  belongs_to :chef_attribute
  belongs_to :ku_user
end
