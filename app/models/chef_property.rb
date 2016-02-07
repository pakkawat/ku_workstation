class ChefProperty < ActiveRecord::Base
  belongs_to :chef_resource
  validates :value, presence: true
end
