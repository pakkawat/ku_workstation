module ResourceGenerator
	def ResourceGenerator.package(resource_name,chef_attributes)
		str_code = <<-RUBY
			puts ""
			puts "package " + resource_name + " do"
			puts "  action :install"
			puts "end"
		RUBY
		return str_code
	end
end