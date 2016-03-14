class ChefAttribute < ActiveRecord::Base
  belongs_to :chef_resource
  #validates :value, :presence => { :message => "Value can't be blank" }
  has_many :chef_values, dependent: :destroy
  has_many :ku_users, through: :chef_values
end
