class Program < ActiveRecord::Base
	has_many :program_file, dependent: :destroy
end
