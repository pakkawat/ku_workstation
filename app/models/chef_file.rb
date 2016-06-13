class ChefFile < ActiveRecord::Base
  has_many :personal_chef_resources, dependent: :destroy
end
