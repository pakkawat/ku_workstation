class PersonalChefResource < ActiveRecord::Base
  has_many :user_remove_resources, dependent: :destroy
  has_many :ku_users, through: :user_remove_resources
  has_many :personal_program_chefs, dependent: :destroy
  has_many :personal_programs, through: :personal_program_chefs
  has_many :chef_properties, dependent: :destroy
  belongs_to :chef_file
  accepts_nested_attributes_for :chef_properties
  default_scope { order("priority ASC") }
  has_many :user_errors, dependent: :destroy
  has_many :ku_users, through: :user_errors
end
