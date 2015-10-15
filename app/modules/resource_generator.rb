module ResourceGenerator
require 'uri'
	def ResourceGenerator.resource(resource)
		if resource.resource_type == "Repository"
			ResourceGenerator.package(resource.resource_name, resource.chef_attributes)
		elsif resource.resource_type == "Zip"
			ResourceGenerator.remote_file(resource.chef_attributes)
		elsif resource.resource_type == "Deb"
			ResourceGenerator.deb(resource.chef_attributes)
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

	def ResourceGenerator.remote_file(chef_attributes)
		url = chef_attributes[0].att_value
		uri = URI.parse(url)
		str_code = ""
		str_code += "src_filename = \"" + File.basename(uri.path) + "\"\n"
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

	def ResourceGenerator.deb(chef_attributes)
		url = chef_attributes[0].att_value
		uri = URI.parse(url)
		str_code = ""
		str_code += "src_filename = \"" + File.basename(uri.path) + "\"\n"
		str_code += "src_filepath = \"\#\{Chef::Config\[:file_cache_path\]\}\/\#\{src_filename\}\"\n"
		str_code += "\n"
		str_code += "remote_file src_filepath do\n"
		str_code += "  source \"" + chef_attributes[0].att_value + "\"\n"
		str_code += "  mode '0755'\n"
		str_code += "  not_if \{ ::File.exists?(src_filepath) \}\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "dpkg_package \"\#\{src_filename\}\" do\n"
		str_code += "  source src_filepath\n"
		str_code += "  action :install\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_resources(remove_files)
		str_code = ""
		remove_files.each do |file|
			str_code += remove_file_resource(file)
			str_code += uninstall_program_resource(file)
		end
		return str_code
	end

	def self.remove_file_resource(file)
		str_code = ""

		if file.resource_type == "Zip" || file.resource_type == "Deb" # Repo does not has a file to delete
			if file.att_type == "extract_path"
				str_code += " test Remove extract path\n"
				str_code += file.att_value+"\n"
				str_code += "\n"
				str_code += "\n"
				str_code += "\n"
				str_code += "\n"
				str_code += "\n"
			else # source
				url = file.att_value
				uri = URI.parse(url)
				str_code += "file \"\#\{Chef::Config\[:file_cache_path\]\}\/" + File.basename(uri.path) + "\" do\n"
				str_code += "  action :delete\n"
				str_code += "  only_if \{ ::File.exists?(\"\#\{Chef::Config\[:file_cache_path\]\}\/" + File.basename(uri.path) + "\") \}\n"
				str_code += "end\n"
				str_code += "\n"
			end
		end

		return str_code
	end

	def self.uninstall_program_resource(file)
		str_code = ""

		if file.resource_type == "Repository"
			str_code += "package '#{file.resource_name}' do\n"
			str_code += "  action :remove\n"
			str_code += "end\n"
			str_code += "\n"
		elsif file.resource_type == "Deb"
			str_code += "dpkg_package '#{file.resource_name}' do\n"
			str_code += "  action :remove\n"
			str_code += "end\n"
			str_code += "\n"
		elsif file.resource_type == "Zip"
			if file.att_type == "source" # because Zip type have 2 record (source, extract_path) this will lead to duplicate code then just select one
				str_code += "test uninstall program from Zip\n"
				str_code += file.resource_name+"\n"
				str_code += "\n"
			end
		end

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

	def ResourceGenerator.remote_file222(chef_attributes)
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
