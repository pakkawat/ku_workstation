class UserError < ActiveRecord::Base
  belongs_to :ku_user
  belongs_to :chef_resource
  belongs_to :personal_chef_resource
end
