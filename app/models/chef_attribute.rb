class ChefAttribute < ActiveRecord::Base
  belongs_to :chef_resource
  #validates :value, :presence => { :message => "Value can't be blank" }
end
