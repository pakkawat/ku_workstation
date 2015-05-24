class Subject < ActiveRecord::Base
  has_many :user_subjects, dependent: :destroy
  has_many :ku_users, through: :user_subjects
  has_many :programs_subjects, dependent: :destroy
  has_many :programs, through: :programs_subjects
end
