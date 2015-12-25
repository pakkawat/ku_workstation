module ResourceGenerator
require 'uri'
	def ResourceGenerator.resource(chef_resource)
		if chef_resource.resource_type == "Repository"
			ResourceGenerator.install_from_repository(chef_resource.resource_name)
		elsif chef_resource.resource_type == "Deb"
			ResourceGenerator.install_from_deb(chef_resource)
		elsif chef_resource.resource_type == "Source"
			ResourceGenerator.install_from_source(chef_resource)
		elsif chef_resource.resource_type == "Download"
			ResourceGenerator.download_file(chef_resource)
		elsif chef_resource.resource_type == "Extract"
			ResourceGenerator.extract_file(chef_resource)
		end
	end

	def ResourceGenerator.uninstall_resource(chef_resource)
		if chef_resource.resource_type == "Repository"
			ResourceGenerator.uninstall_from_repository(chef_resource.resource_name)
		elsif chef_resource.resource_type == "Deb"
			ResourceGenerator.uninstall_from_deb(chef_resource)
		elsif chef_resource.resource_type == "Source"
			ResourceGenerator.uninstall_from_source(chef_resource)
		elsif chef_resource.resource_type == "Download"
			ResourceGenerator.delete_download_file(chef_resource)
		elsif chef_resource.resource_type == "Extract"
			ResourceGenerator.delete_extract_file(chef_resource)
		end
	end

	def ResourceGenerator.install_from_repository(resource_name)
		str_code = ""
		str_code += "package '#{resource_name}' do\n"
		str_code += "  action :install\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.uninstall_from_repository(resource_name)
		str_code = ""
		str_code += "package '#{resource_name}' do\n"
		str_code += "  action :remove\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.install_from_deb(chef_resource)
		source_file = chef_resource.chef_attributes.where(:att_type => "source_file").pluck(:att_value)
		str_code = ""
		str_code += "src_filepath = \"\#\{Chef::Config\[:file_cache_path\]\}\/#{source_file}\"\n"
		str_code += "\n"
		str_code += "dpkg_package \"#{chef_resource.resource_name}\" do\n"
		str_code += "  source src_filepath\n"
		str_code += "  action :install\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.uninstall_from_deb(chef_resource)
		#source_file = chef_resource.chef_attributes.where(:att_type => "source_file").pluck(:att_value)
		str_code = ""
		str_code += "dpkg_package \"#{chef_resource.resource_name}\" do\n"
		str_code += "  action :remove\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.install_from_source(chef_resource)
		str_code = ""
		str_code += "install_from_source\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.uninstall_from_source(chef_resource)
		str_code = ""
		str_code += "uninstall_from_source\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.download_file(chef_resource)
		url = chef_resource.chef_attributes.where(:att_type => "download_url").pluck(:att_value)
		uri = URI.parse(url)
		file_name = File.basename(uri.path)
		str_code = ""
		str_code += "src_filename = \"" + file_name + "\"\n"
		str_code += "src_filepath = \"\#\{Chef\:\:Config\[\:file_cache_path\]\}\/\#\{src_filename\}\"\n"
		str_code += "remote_file src_filepath do\n"
		str_code += "  source \"" + url + "\"\n"
		str_code += "  mode '0755'\n"
		str_code += "  not_if \{ \:\:File.exists?(\#\{src_filepath\}) \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_download_file(chef_resource)
		url = chef_resource.chef_attributes.where(:att_type => "download_url").pluck(:att_value)
		uri = URI.parse(url)
		file_name = File.basename(uri.path)
		str_code = ""
		str_code += "file \"\#\{Chef::Config\[:file_cache_path\]\}\/" + file_name + "\" do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?(\"\#\{Chef::Config\[:file_cache_path\]\}\/" + file_name + "\") \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.extract_file(chef_resource)
		source_file = chef_resource.chef_attributes.where(:att_type => "source_file").pluck(:att_value)
		extract_to = chef_resource.chef_attributes.where(:att_type => "extract_to").pluck(:att_value)
		str_code = ""
		str_code += "bash 'extract_module' do\n"
		str_code += "  cwd Chef\:\:Config\[\:file_cache_path\]\n"
		str_code += "  code \<\<\-EOH\n"
		str_code += "    mkdir -p #{extract_to}\n"
		str_code += "    tar xzf #{source_file} \-C #{extract_to}\n"
		str_code += "    EOH\n"
		str_code += "  not_if \{ \:\:File.exists?(#{extract_to}) \}\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_extract_file(chef_resource)
		extract_to = chef_resource.chef_attributes.where(:att_type => "extract_to").pluck(:att_value)
		str_code = ""
		str_code += "directory \"" + extract_to + "\" do\n"
		str_code += "  recursive true\n"
		str_code += "  action :delete\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

#########################################################################################################################


	def ResourceGenerator.remove_disuse_resource(file)
		if file.resource_type == "Repository"
			remove_repository(file)
		elsif file.resource_type == "Deb"
			remove_deb(file)
		elsif file.resource_type == "Source"
			remove_source(file)
		elsif file.resource_type == "Download"
			remove_download_file(file)
		elsif file.resource_type == "Extract"
			remove_extract_file(file)
		end
	end

	def self.remove_repository(file)
		str_code = ""
		str_code += "package '#{file.resource_name}' do\n"
		str_code += "  action :remove\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_deb(file)
		str_code = ""
		str_code += "dpkg_package \"#{file.resource_name}\" do\n"
		str_code += "  action :remove\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_source(file)
		str_code = ""
		str_code += "uninstall_from_source\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_download_file(file)
		url = file.att_value
		uri = URI.parse(url)
		file_name = File.basename(uri.path)
		str_code = ""
		str_code += "file \"\#\{Chef::Config\[:file_cache_path\]\}\/" + file_name + "\" do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?(\"\#\{Chef::Config\[:file_cache_path\]\}\/" + chef_resource.file_name + "\") \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_extract_file(file)
		str_code = ""
		if file.att_type == "extract_to"
			extract_to = file.att_value
			str_code += "directory \"" + extract_to + "\" do\n"
			str_code += "  recursive true\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		end
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
				#str_code += " test Remove extract path\n"
				str_code += "directory " + file.att_value + " do\n"
				str_code += "  recursive true\n"
				str_code += "  action :delete\n"
				str_code += "end\n"
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

	def ResourceGenerator.uninstall_resource222(chef_resource)
		str_code = ""
		if chef_resource.resource_type == "Repository"
			str_code += "package '#{chef_resource.resource_name}' do\n"
			str_code += "  action :remove\n"
			str_code += "end\n"
			str_code += "\n"
		elsif chef_resource.resource_type == "Dep"
			str_code += "file \"\#\{Chef::Config\[:file_cache_path\]\}\/" + chef_resource.file_name + "\" do\n"
			str_code += "  action :delete\n"
			str_code += "  only_if \{ ::File.exists?(\"\#\{Chef::Config\[:file_cache_path\]\}\/" + chef_resource.file_name + "\") \}\n"
			str_code += "end\n"
			str_code += "\n"
			str_code += "dpkg_package '#{chef_resource.resource_name}' do\n"
			str_code += "  action :remove\n"
			str_code += "end\n"
			str_code += "\n"
		elsif chef_resource.resource_type == "Zip"
			chef_resource.chef_attributes.each do |chef_attribute|
				if chef_attribute.att_type == "extract_path"
					#str_code += " test Remove extract path\n"
					str_code += "directory " + chef_attribute.att_value + " do\n"
					str_code += "  recursive true\n"
					str_code += "  action :delete\n"
					str_code += "end\n"
					str_code += "\n"
				else # source
					url = chef_attribute.att_value
					uri = URI.parse(url)
					str_code += "file \"\#\{Chef::Config\[:file_cache_path\]\}\/" + File.basename(uri.path) + "\" do\n"
					str_code += "  action :delete\n"
					str_code += "  only_if \{ ::File.exists?(\"\#\{Chef::Config\[:file_cache_path\]\}\/" + File.basename(uri.path) + "\") \}\n"
					str_code += "end\n"
					str_code += "\n"
				end
			end
			#to_do uninstall program from source
			str_code += "start uninstall program from source\n"
			str_code += "\n"
		end
	end
end
