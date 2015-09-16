module ResourceGenerator
	def ResourceGenerator.package(resource_name,chef_attributes)
		str_code = "\n"
		str_code += "package '#{resource_name}' do\n"
		str_code += "  action :install\n"
		str_code += "end"
		str_code += ""
		return str_code
	end

	def ResourceGenerator.remote_file(resource_name,chef_attributes)
		str_code = "\n"
		str_code += "remote_file '\#\{Chef\:\:Config\[\:file_cache_path\]\}\/#{resource_name}' do\n"
		str_code += "  mode '0755'\n"
		str_code += "  not_if \{ \:\:File.exists?\(\"\#\{Chef\:\:Config\[\:file_cache_path\]\}\/\#\{resource_name\}\"\) \}"
		str_code += "end"
		str_code += ""
		return str_code
	end

end
