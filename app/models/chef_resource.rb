class ChefResource < ActiveRecord::Base
  has_many :program_chefs, dependent: :destroy
  has_many :programs, through: :program_chefs
  has_many :chef_properties, dependent: :destroy
  accepts_nested_attributes_for :chef_properties
  default_scope { order("priority ASC") }
  has_many :chef_attributes, dependent: :destroy
  has_one :chef_file, dependent: :destroy
  accepts_nested_attributes_for :chef_attributes, reject_if: proc { |attributes| attributes['name'].blank? }, allow_destroy: true
end
