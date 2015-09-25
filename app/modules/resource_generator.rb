module ResourceGenerator

	def ResourceGenerator.resource(resource)
		if resource.resource_type == "Repository"
			ResourceGenerator.package(resource.resource_name, resource.chef_attributes)
		elsif resource.resource_type == "Zip"
			ResourceGenerator.remote_file(resource.resource_name, resource.chef_attributes)
		end
	end


	def ResourceGenerator.package(resource_name, chef_attributes)
		str_code = ""
		str_code += "package '#{resource_name}' do\n"
		str_code += "  " + chef_attributes[0].att_type + " :" + chef_attributes[0].att_value + "\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.remote_file(resource_name,chef_attributes)
		str_code = ""
		str_code += "src_filename = \"#{resource_name}\"\n"
		str_code += "src_filepath = \"\#\{Chef\:\:Config\[\:file_cache_path\]\}\/\#\{src_filename\}\"\n"
		str_code += "extract_path = \"" + chef_attributes[1].att_value + "\"\n"
		str_code += "\n"
		str_code += "remote_file src_filepath do\n"
		str_code += "  source \"" + chef_attributes[0].att_value + "\"\n"
		str_code += "  mode '0755'\n"
		str_code += "  not_if \{ \:\:File.exists?(src_filepath) \}\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "bash 'extract_module' do\n"
		str_code += "  cwd Chef\:\:Config\[\:file_cache_path\]\n"
		str_code += "  code \<\<\-EOH\n"
		str_code += "    mkdir -p \#\{extract_path\}\n"
		str_code += "    tar xzf \#\{src_filename\} \-C \#\{extract_path\}\n"
		str_code += "    EOH\n"
		str_code += "  not_if \{ \:\:File.exists?(extract_path) \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end


	def ResourceGenerator.package222(resource_name,chef_attributes)
		str_code = "\n"
		str_code += "package '#{resource_name}' do\n"
		chef_attributes.each do |key, value|
			str_code += "  " + value[:att_type] + " :" + value[:att_value] + "\n"
		end
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.remote_file222(resource_name,chef_attributes)
		str_code = "\n"
		str_code += "remote_file '\#\{Chef\:\:Config\[\:file_cache_path\]\}\/#{resource_name}' do\n"
		chef_attributes.each do |key, value|
			str_code += "  " + value[:att_type] + " " + value[:att_value] + "\n"
		end
		str_code += "  mode '0755'\n"
		str_code += "  not_if \{ \:\:File.exists?\(\"\#\{Chef\:\:Config\[\:file_cache_path\]\}\/#{resource_name}\"\) \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

end
