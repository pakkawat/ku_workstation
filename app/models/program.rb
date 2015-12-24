class Program < ActiveRecord::Base
	has_many :program_files, dependent: :destroy
	has_many :programs_subjects, dependent: :destroy
	has_many :subjects, through: :programs_subjects
	has_many :chef_resources, dependent: :destroy
    accepts_nested_attributes_for :chef_resources, allow_destroy: true
	#accepts_nested_attributes_for :chef_resources, reject_if: lambda {|attributes| attributes[:resource_name].blank?}, allow_destroy: true
	has_many :remove_files, dependent: :destroy
	has_many :users_programs, dependent: :destroy
end
