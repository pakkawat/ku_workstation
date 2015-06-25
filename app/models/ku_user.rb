class KuUser < ActiveRecord::Base
  #attr_accessible :ku_id, :username, :password, :firstname, :lastname, :sex, :email, :degree_level, :faculty, :campus, :major_field, :status
  attr_accessor :remember_token
  has_many :user_subjects, dependent: :destroy
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

  # Returns the hash digest of the given string.
  def KuUser.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def KuUser.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = KuUser.new_token
    update_attribute(:remember_digest, KuUser.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  def user_programs(reload=false)
    @user_programs = nil if reload 
    @user_programs ||=Program.find_by_sql("SELECT p.id, p.program_name, p.note FROM programs p INNER JOIN programs_subjects ps on p.id = ps.program_id INNER JOIN user_subjects us on us.subject_id = ps.subject_id WHERE us.ku_user_id = #{self.id} AND us.user_enabled = true AND ps.program_enabled = true")
  end
end
