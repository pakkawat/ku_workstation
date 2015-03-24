class KuUser < ActiveRecord::Base
  #attr_accessible :ku_id, :username, :password, :firstname, :lastname, :sex, :email, :degree_level, :faculty, :campus, :major_field, :status
  has_many :user_subjects
  has_many :subjects, through: :user_subjects
  before_save { self.email = email.downcase }
  validates :ku_id, presence: true, length: { maximum: 15 }  
  validates :username, presence: true, length: { maximum: 50 }
  validates :password, length: { minimum: 6 }
  validates :firstname, presence: true, length: { maximum: 50 }
  validates :lastname, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
end
