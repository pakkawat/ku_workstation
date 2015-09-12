module ResourceGenerator
	def ResourceGenerator.package(resource_name,chef_attributes)
		str_code = "\n"\
					"package '#{resource_name}' do\n"\
					"  action :install\n"\
					"end\n"
		return str_code
	end
end