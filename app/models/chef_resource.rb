class ChefResource < ActiveRecord::Base
	default_scope { order("priority ASC") }
	belongs_to :program
	has_many :chef_attributes, :dependent => :destroy
	accepts_nested_attributes_for :chef_attributes, reject_if: :all_blank, allow_destroy: true
end
