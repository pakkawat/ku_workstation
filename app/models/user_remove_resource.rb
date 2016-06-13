class UserRemoveResource < ActiveRecord::Base
  belongs_to :ku_user
  belongs_to :personal_chef_resource
end
