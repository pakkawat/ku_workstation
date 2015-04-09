class Subject < ActiveRecord::Base
  has_many :user_subjects, dependent: :destroy
  has_many :ku_users, through: :user_subjects
end
