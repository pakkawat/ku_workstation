class ProgramsSubject < ActiveRecord::Base
  belongs_to :program
  belongs_to :subject
end
