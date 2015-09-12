class ChefResource < ActiveRecord::Base
  belongs_to :program
  has_many :chef_attributes, :dependent => :destroy
  accepts_nested_attributes_for :chef_attributes, reject_if: lambda {|attributes| attributes[:att_value].blank?}, allow_destroy: true
end
