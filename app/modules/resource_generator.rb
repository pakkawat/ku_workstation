module ResourceGenerator
require 'uri'
	def ResourceGenerator.resource(chef_resource)
		if chef_resource.resource_type == "Repository"
			ResourceGenerator.install_from_repository(chef_resource)
		elsif chef_resource.resource_type == "Deb"
			ResourceGenerator.install_from_deb(chef_resource)
		elsif chef_resource.resource_type == "Source"
			ResourceGenerator.install_from_source(chef_resource)
		elsif chef_resource.resource_type == "Download"
			ResourceGenerator.download_file(chef_resource)
		elsif chef_resource.resource_type == "Extract"
			ResourceGenerator.extract_file(chef_resource)
		elsif chef_resource.resource_type == "Copy_file"
			ResourceGenerator.copy_file(chef_resource)
		elsif chef_resource.resource_type == "Create_file"
			ResourceGenerator.create_file(chef_resource)
		end
	end

	def ResourceGenerator.uninstall_resource(chef_resource)
		if chef_resource.resource_type == "Repository"
			ResourceGenerator.uninstall_from_repository(chef_resource)
		elsif chef_resource.resource_type == "Deb"
			ResourceGenerator.uninstall_from_deb(chef_resource)
		elsif chef_resource.resource_type == "Source"
			ResourceGenerator.uninstall_from_source(chef_resource)
		elsif chef_resource.resource_type == "Download"
			ResourceGenerator.delete_download_file(chef_resource)
		elsif chef_resource.resource_type == "Extract"
			ResourceGenerator.delete_extract_file(chef_resource)
		elsif chef_resource.resource_type == "Copy_file"
			ResourceGenerator.delete_copy_file(chef_resource)
		elsif chef_resource.resource_type == "Create_file"
			ResourceGenerator.delete_create_file(chef_resource)
		end
	end

	def ResourceGenerator.install_from_repository(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value)
		str_code = ""
		str_code += "\%w\{#{value}\}.each do \|pkg\|\n"
		str_code += "  package pkg do\n"
		str_code += "    action :install\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.uninstall_from_repository(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value)
		str_code = ""
		str_code += "\%w\{#{value}\}.each do \|pkg\|\n"
		str_code += "  package pkg do\n"
		str_code += "    action :remove\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.install_from_deb2(chef_resource)
		source_file = chef_resource.chef_attributes.where(:att_type => "source_file").pluck(:att_value).first
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

	def ResourceGenerator.install_from_deb(chef_resource)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value)
		program_name = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value)

		str_code = ""
		str_code += "dpkg_package \"#{program_name}\" do\n"
		str_code += "  source '#{source_file}'\n"
		str_code += "  action :install\n"
		str_code += "  ignore_failure true\n"
		str_code += "  notifies :run, 'execute[apt-get-install-f]', :immediately\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "execute 'apt-get-install-f' do\n"
		str_code += "  command 'sudo apt-get install -f'\n"
		str_code += "  action :run\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.uninstall_from_deb(chef_resource)
		program_name = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value)
		str_code = ""
		str_code += "dpkg_package '#{program_name}' do\n"
		str_code += "  action :remove\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.install_from_source(chef_resource)
		program_name = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value)
		str_code = ""
		str_code += "#{program_name} install_from_source\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.uninstall_from_source(chef_resource)
		program_name = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value)
		str_code = ""
		str_code += "#{program_name} uninstall_from_source\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.download_file(chef_resource)
		url = chef_resource.chef_properties.where(:value_type => "download_url").pluck(:value)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value)

		src_filepath = File.dirname(source_file)
		paths = get_path(src_filepath)

		str_code = ""
		str_code += "%w[ #{paths} ].each do |path|\n"
		str_code += "  directory path do\n"
		str_code += "    owner 'root'\n"
		str_code += "    group 'root'\n"
		str_code += "    mode '0755'\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"


		str_code += "remote_file '#{source_file}' do\n"
		str_code += "  source '#{url}'\n"
		str_code += "  mode '0755'\n"
		str_code += "  action :create\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_download_file(chef_resource)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value)
		str_code = ""
		str_code += "file '#{source_file}' do\n"
		str_code += "  action :delete\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.extract_file(chef_resource)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value)
		extract_to = chef_resource.chef_properties.where(:value_type => "extract_to").pluck(:value)

		src_filepath = File.dirname(source_file)
		path = File.dirname(extract_to)
		paths = get_path(path)

		str_code = ""
		str_code += "%w[ #{paths} ].each do |path|\n"
		str_code += "  directory path do\n"
		str_code += "    owner 'root'\n"
		str_code += "    group 'root'\n"
		str_code += "    mode '0755'\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "bash 'extract_module' do\n"
		str_code += "  cwd ::File.dirname(#{src_filepath})\n"
		str_code += "  code \<\<\-EOH\n"
		#str_code += "    mkdir -p \"#{extract_to}\"\n"
		str_code += "    tar xzf \"#{source_file}\" \-C \"#{extract_to}\"\n"
		str_code += "    EOH\n"
		str_code += "  not_if \{ \:\:File.exists?(\"#{extract_to}\") \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_extract_file(chef_resource)
		extract_to = chef_resource.chef_properties.where(:value_type => "extract_to").pluck(:value)
		str_code = ""
		str_code += "directory '" + extract_to + "' do\n"
		str_code += "  recursive true\n"
		str_code += "  action :delete\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.config_file(chef_resource, program)
		value = chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
		file_name = File.basename(value)
		str_code = ""
		if File.exists?("/home/ubuntu/chef-repo/cookbooks/" + program.program_name + "/templates/" + file_name + ".erb")
			str_code += "template '#{value}' do\n"
			str_code += "  source '#{file_name}.erb'\n"
			str_code += "  owner 'root'\n"
			str_code += "  group 'root'\n"
			str_code += "  mode '0755'\n"
			str_code += "end\n"
			str_code += "\n"
		end
		str_code += "file '/var/lib/tomcat7/webapps/ROOT/sharedfile/#{file_name}' do\n"
		str_code += "  content IO.read('#{value}')\n"
		str_code += "  action :create\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.copy_file(chef_resource)
		copy_type = chef_resource.chef_properties.where(:value_type => "copy_type").pluck(:value)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value)
		destination_file = chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value)
		str_code = ""
		if copy_type == "file"
			path = File.dirname(destination_file)
			paths = get_path(path)
			str_code += "%w[ #{paths} ].each do |path|\n"
			str_code += "  directory path do\n"
			str_code += "    owner 'root'\n"
			str_code += "    group 'root'\n"
			str_code += "    mode '0755'\n"
			str_code += "  end\n"
			str_code += "end\n"
			str_code += "\n"
			str_code += "file '#{destination_file}' do\n"
			str_code += "  content IO.read('#{source_file}')\n"
			str_code += "  action :create\n"
			str_code += "end\n"
			str_code += "\n"
		else
			paths = get_path(destination_file)
			str_code += "%w[ #{paths} ].each do |path|\n"
			str_code += "  directory path do\n"
			str_code += "    owner 'root'\n"
			str_code += "    group 'root'\n"
			str_code += "    mode '0755'\n"
			str_code += "  end\n"
			str_code += "end\n"
			str_code += "\n"
			str_code += "if Dir.entries('#{destination_file}').size == 2\n" # empty folder (have two links "." and ".." only)
			str_code += "  execute 'copy_all_file_in_folder' do\n"
			str_code += "    command 'cp -r #{source_file}/. #{destination_file}'\n"
			str_code += "  end\n"
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end

	def ResourceGenerator.delete_copy_file(chef_resource)
		copy_type = chef_resource.chef_properties.where(:value_type => "copy_type").pluck(:value)
		destination_file = chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value)
		str_code = ""
		if copy_type == "file"
			str_code += "file '#{destination_file}' do\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		else
			str_code += "directory '#{destination_file}' do\n"
			str_code += "  recursive true\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end

	def get_path(path)
		paths = path.split("/")
		if paths.first == ""
			paths.shift
		end
		arr = Array.new
		index = 0
		paths.each do |p|
			if index != 0
				arr.push(arr.at(index-1)+"/"+p)
			else
				arr.push("/"+p)
			end
			index = index + 1
		end
		str_temp = ""
		arr.each do |a|
			str_temp = str_temp + a + " "
		end
		return str_temp
	end


	def ResourceGenerator.create_file(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "created_file").pluck(:value)
		path = File.dirname(value)
		paths = get_path(path)
		file_name = File.basename(value)
		str_code = ""
		str_code += "%w[ #{paths} ].each do |path|\n"
		str_code += "  directory path do\n"
		str_code += "    owner 'root'\n"
		str_code += "    group 'root'\n"
		str_code += "    mode '0755'\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "template '#{value}' do\n"
		str_code += "  source '#{file_name}.erb'\n"
		str_code += "  owner 'root'\n"
		str_code += "  group 'root'\n"
		str_code += "  mode '0755'\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_create_file(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "created_file").pluck(:value)
		str_code = ""
		str_code += "file '#{value}' do\n"
		str_code += "  action :delete\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

#########################################################################################################################


	def ResourceGenerator.remove_disuse_resource(remove_resource)
		if remove_resource.resource_type == "Repository"
			remove_repository(remove_resource)
		elsif remove_resource.resource_type == "Deb"
			remove_deb(remove_resource)
		elsif remove_resource.resource_type == "Source"
			remove_source(remove_resource)
		elsif remove_resource.resource_type == "Download"
			remove_download_file(remove_resource)
		elsif remove_resource.resource_type == "Extract"
			remove_extract_file(remove_resource)
		elsif remove_resource.resource_type == "Config_file"
			remove_config_file(remove_resource)
		elsif remove_resource.resource_type == "Copy_file"
			remove_copy_file(remove_resource)
		elsif remove_resource.resource_type == "Create_file"
			remove_create_file(remove_resource)
		end
	end

	def self.remove_repository(remove_resource)
		str_code = ""
		str_code += "\%w\{#{remove_resource.value}\}.each do \|pkg\|\n"
		str_code += "  package pkg do\n"
		str_code += "    action :remove\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_deb(remove_resource)
		str_code = ""
		str_code += "dpkg_package '#{remove_resource.value}' do\n"
		str_code += "  action :remove\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_source(remove_resource)
		str_code = ""
		str_code += "#{remove_resource.value} uninstall_from_source\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_download_file(remove_resource)
		str_code = ""
		str_code += "file \"\#\{Chef::Config\[:file_cache_path\]\}\/" + remove_resource.value + "\" do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?(\"\#\{Chef::Config\[:file_cache_path\]\}\/" + remove_resource.value + "\") \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_extract_file(remove_resource)
		str_code = ""
		str_code += "directory '" + remove_resource.value + "' do\n"
		str_code += "  recursive true\n"
		str_code += "  action :delete\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_config_file(remove_resource)
		file_name = File.basename(remove_resource.value)
		program = Program.find(remove_resource.program_id)
		path_to_file = "/home/ubuntu/chef-repo/cookbooks/" + program.program_name + "/templates/" + file_name + ".erb"
		File.delete(path_to_file) if File.exist?(path_to_file)

		str_code = ""
		str_code += "file '/var/lib/tomcat7/webapps/ROOT/sharedfile/#{file_name}' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/sharedfile/#{file_name}') \}\n"
		str_code += "end\n"
		str_code += "\n"
	end

	def self.remove_copy_file(remove_resource)
		str_code = ""
		if remove_resource.value_type == "file"
			str_code += "file '#{remove_resource.value}' do\n"
			str_code += "  action :delete\n"
			str_code += "  only_if \{ ::File.exists?('#{remove_resource.value}') \}\n"
			str_code += "end\n"
			str_code += "\n"
		else
			str_code += "directory '#{remove_resource.value}' do\n"
			str_code += "  recursive true\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end

	def self.remove_create_file(remove_resource)
		file_name = File.basename(remove_resource.value)
		program = Program.find(remove_resource.program_id)
		path_to_file = "/home/ubuntu/chef-repo/cookbooks/" + program.program_name + "/templates/" + file_name + ".erb"
		File.delete(path_to_file) if File.exist?(path_to_file)

		str_code = ""
		str_code += "file '#{remove_resource.value}' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('#{remove_resource.value}') \}\n"
		str_code += "end\n"
		str_code += "\n"
	end

end
