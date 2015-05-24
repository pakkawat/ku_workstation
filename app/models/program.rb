class Program < ActiveRecord::Base
  has_many :program_files, dependent: :destroy
  has_many :programs_subjects, dependent: :destroy
  has_many :subjects, through: :programs_subjects
end
