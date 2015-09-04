class Program < ActiveRecord::Base
  has_many :program_files, dependent: :destroy
  has_many :programs_subjects, dependent: :destroy
  has_many :subjects, through: :programs_subjects
  accepts_nested_attributes_for :chef_resources, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
end
