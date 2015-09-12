module ResourceGenerator
	def ResourceGenerator.package(resource_name,chef_attributes)
		str_code = "\n"
		str_code += "package '#{resource_name}' do\n"
		str_code += "  action :install\n"
		str_code += "end"
		str_code += ""
		return str_code
	end
end