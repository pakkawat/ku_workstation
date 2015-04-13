class Program < ActiveRecord::Base
	has_many :program_files, dependent: :destroy
end
