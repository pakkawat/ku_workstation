class UserSubject < ActiveRecord::Base
  belongs_to :ku_user
  belongs_to :subject
end
