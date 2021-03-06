module ResourceGenerator
#require 'uri'
	def ResourceGenerator.resource(chef_resource, program)
		@program = program
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
		elsif chef_resource.resource_type == "Move_file"
			ResourceGenerator.move_file(chef_resource)
		elsif chef_resource.resource_type == "Execute_command"
			ResourceGenerator.execute_command(chef_resource)
		elsif chef_resource.resource_type == "Bash_script"
			ResourceGenerator.bash_script(chef_resource)
		elsif chef_resource.resource_type == "Config_file"
			ResourceGenerator.config_file(chef_resource)
		end
	end

	def ResourceGenerator.uninstall_resource(chef_resource, program)
		@program = program
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
		elsif chef_resource.resource_type == "Move_file"
			ResourceGenerator.delete_move_file(chef_resource)
		elsif chef_resource.resource_type == "Config_file"
			ResourceGenerator.delete_config_file(chef_resource)
		elsif chef_resource.resource_type == "Bash_script"
			ResourceGenerator.delete_bash_script_file(chef_resource)
		elsif chef_resource.resource_type == "Execute_command"
			ResourceGenerator.delete_execute_command_file(chef_resource)
		end
	end

	def ResourceGenerator.install_from_repository(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "\%w\{#{value}\}.each do \|pkg\|\n"
		str_code += "  package pkg do\n"
		str_code += "    action :install\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.uninstall_from_repository(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
		str_code = ""
		str_code += print_log(chef_resource.id)
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
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		program_name = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first

		#src_path = File.dirname(source_file)
		#src_file_name = File.basename(source_file)
		#src_paths, src_last_path = get_path(src_path)

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "dpkg_package \"#{program_name}\" do\n"
		str_code += "  source '#{source_file}'\n"
		str_code += "  action :install\n"
		#str_code += "  ignore_failure true\n" # เพื่อให้แสดง error ที่แท้จริง
		#str_code += "  notifies :run, 'execute[apt-get-install-f]', :immediately\n"
		str_code += "end\n"
		str_code += "\n"
		#str_code += "execute 'apt-get-install-f' do\n"
		#str_code += "  command 'sudo apt-get -f install -y'\n"
		#str_code += "  action :run\n"
		#str_code += "end\n"
		#str_code += "\n"
		return str_code
	end

	def ResourceGenerator.uninstall_from_deb(chef_resource)
		program_name = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "dpkg_package '#{program_name}' do\n"
		str_code += "  action :remove\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.install_from_source(chef_resource)
		program_name = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		configure_optional = chef_resource.chef_properties.where(:value_type => "configure_optional").pluck(:value).first

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "bash 'install_#{program_name}_from_source' do\n"
		str_code += "  user 'root'\n"
		str_code += "  cwd '#{source_file}'\n"
		str_code += "  code <<-EOH\n"
		str_code += "  ./configure #{configure_optional}\n"
		str_code += "  make\n"
		str_code += "  sudo make install\n"
		str_code += "  EOH\n"
		str_code += "  not_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/install_from_source/chef_resource_#{chef_resource.id}.txt') \}\n" # เพื่อให้แสดง error ที่แท้จริงดังนั้นไม่ต้องตรวจสอบว่า folder ว่างหรือไม่
		#str_code += "  not_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/install_from_source/chef_resource_#{chef_resource.id}.txt') || Dir.entries('#{source_file}').size == 2 \}\n"
		str_code += "end\n"
		str_code += "\n"

		#เพื่อป้องกันไม่ให้เกิดการ compile และ install 2 ครั้ง (เพราะแต่ละครั้งที่เกิดการ apply_change จะทำ ssh 2 ครั้ง)
		str_code += "file '/var/lib/tomcat7/webapps/ROOT/install_from_source/chef_resource_#{chef_resource.id}.txt' do\n"
		str_code += "  content ''\n"
		str_code += "  mode '0755'\n"
		str_code += "end\n"
		str_code += "\n"

		return str_code
	end

	def ResourceGenerator.uninstall_from_source(chef_resource)
		program_name = chef_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "bash 'uninstall_#{program_name}_from_source' do\n"
		str_code += "  user 'root'\n"
		str_code += "  cwd '#{source_file}'\n"
		str_code += "  code <<-EOH\n"
		str_code += "  sudo make uninstall\n"
		str_code += "  EOH\n"
		#str_code += "  only_if \{ Dir.exists?('#{source_file}') \}\n"
		str_code += "end\n"
		str_code += "\n"

		str_code += "file '/var/lib/tomcat7/webapps/ROOT/install_from_source/chef_resource_#{chef_resource.id}.txt' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/install_from_source/chef_resource_#{chef_resource.id}.txt') \}\n"
		str_code += "end\n"
		str_code += "\n"

		return str_code
	end

	def ResourceGenerator.download_file(chef_resource)
		url = chef_resource.chef_properties.where(:value_type => "download_url").pluck(:value).first
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first

		src_path = File.dirname(source_file)
		#src_file_name = File.basename(source_file)
		src_paths, src_last_path = get_path(src_path)

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "%w[ #{src_paths} ].each do |path|\n"
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
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first

		#src_path = File.dirname(source_file)
		#src_file_name = File.basename(source_file)
		#src_paths, src_last_path = get_path(src_path)

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "file '#{source_file}' do\n"
		str_code += "  action :delete\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.extract_file(chef_resource)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		extract_to = chef_resource.chef_properties.where(:value_type => "extract_to").pluck(:value).first

		src_path = File.dirname(source_file)
		#src_file_name = File.basename(source_file)
		src_paths, src_last_path = get_path(src_path)

		#des_path = File.dirname(extract_to)
		#des_file_name = File.basename(extract_to)
		des_paths, des_last_path = get_path(extract_to)

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "%w[ #{des_paths} ].each do |path|\n"
		str_code += "  directory path do\n"
		str_code += "    owner 'root'\n"
		str_code += "    group 'root'\n"
		str_code += "    mode '0777'\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "bash 'extract_module' do\n"
		str_code += "  user 'root'\n"
		str_code += "  cwd ::File.dirname('#{src_path}')\n"
		str_code += "  code \<\<\-EOH\n"
		#str_code += "    mkdir -p \"#{extract_to}\"\n"
		str_code += "    tar xf #{source_file} \-C #{des_last_path}\n"
		str_code += "    EOH\n"
		str_code += "  only_if \{ Dir.entries('#{des_last_path}').size == 2 \}\n" # จะแตกไฟล์ก็ต่อเมื่อ folder ปลายทางว่าง
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_extract_file(chef_resource)
		extract_to = chef_resource.chef_properties.where(:value_type => "extract_to").pluck(:value).first

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "directory '#{extract_to}' do\n"
		str_code += "  recursive true\n"
		str_code += "  action :delete\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.config_file(chef_resource)
		source_file = chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first

		#src_path = File.dirname(source_file)
		src_file_name = File.basename(source_file)
		#src_paths, src_last_path = get_path(src_path)

		str_code = ""
		str_code += print_log(chef_resource.id)
		if File.exists?("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + src_file_name + ".erb")
			str_code += "template '#{source_file}' do\n"
			str_code += "  source '#{src_file_name}.erb'\n"
			str_code += "  owner 'root'\n"
			str_code += "  group 'root'\n"
			str_code += "  mode '0755'\n"
			str_code += "end\n"
			str_code += "\n"
		end
		str_code += "execute 'copy_edit_file' do\n"
		str_code += "  user 'root'\n"
		str_code += "  command 'cp #{source_file} /var/lib/tomcat7/webapps/ROOT/sharedfile/#{src_file_name}'\n"
		str_code += "  only_if { ::File.exist?('#{source_file}') }\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_config_file(chef_resource)
		file_name = File.basename(chef_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first)

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "file '/var/lib/tomcat7/webapps/ROOT/sharedfile/#{file_name}' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/sharedfile/#{file_name}') \}\n"
		str_code += "end\n"
		str_code += "\n"
	end

	def ResourceGenerator.copy_file(chef_resource)
		copy_type = chef_resource.chef_properties.where(:value_type => "copy_type").pluck(:value).first
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		destination_file = chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
		str_code = ""
		if copy_type == "file"
			#src_path = File.dirname(source_file)
			#src_file_name = File.basename(source_file)
			#src_paths, src_last_path = get_path(src_path)

			#des_path = File.dirname(destination_file)
			#des_file_name = File.basename(destination_file)
			des_paths, des_last_path = get_path(destination_file)

			str_code += "%w[ #{des_paths} ].each do |path|\n"
			str_code += "  directory path do\n"
			str_code += "    owner 'root'\n"
			str_code += "    group 'root'\n"
			str_code += "    mode '0755'\n"
			str_code += "  end\n"
			str_code += "end\n"
			str_code += "\n"
			#str_code += "if ::File.exist?('#{src_last_path}\/#{src_file_name}')\n"
			#str_code += "  file '#{des_last_path}\/#{src_file_name}' do\n"
			#str_code += "    content IO.read('#{src_last_path}\/#{src_file_name}')\n"
			#str_code += "    action :create\n"
			#str_code += "  end\n"
			#str_code += "end\n"
			#str_code += "\n"
			str_code += "execute 'copy_file' do\n"
			str_code += "  user 'root'\n"
			str_code += "  command 'cp #{source_file} #{des_last_path}\/#{src_file_name}'\n"
			str_code += "  only_if { File.exist?('#{source_file}') && !File.exist?('#{des_last_path}\/#{src_file_name}')}\n"
			str_code += "end\n"
			str_code += "\n"
		elsif copy_type == "folder"
			#src_path = File.dirname(source_file)
			#src_file_name = File.basename(source_file)
			src_paths, src_last_path = get_path(source_file)

			#des_path = File.dirname(destination_file)
			#des_file_name = File.basename(destination_file)
			des_paths, des_last_path = get_path(destination_file)

			str_code += "%w[ #{des_paths} ].each do |path|\n"
			str_code += "  directory path do\n"
			str_code += "    owner 'root'\n"
			str_code += "    group 'root'\n"
			str_code += "    mode '0755'\n"
			str_code += "  end\n"
			str_code += "end\n"
			str_code += "\n"
			#str_code += "if Dir.entries('#{des_last_path}').size == 2\n" # empty folder (have two links "." and ".." only)
			#str_code += "  execute 'copy_all_file_in_folder' do\n"
			#str_code += "    command 'cp -r #{src_last_path}\/. #{des_last_path}'\n"
			#str_code += "  end\n"
			#str_code += "end\n"
			#str_code += "\n"
			str_code += "execute 'copy_all_file_in_folder' do\n"
			str_code += "  command 'cp -r #{src_last_path}\/. #{des_last_path}'\n"
			str_code += "  only_if { Dir.entries('#{des_last_path}').size == 2 }\n" # แสดงว่าจะเกิดการ copy folder ได้ก็ต่อเมื่อทำการ copy ไปที่ folder ที่ว่างอยู่เท่านั้น
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end

	def ResourceGenerator.delete_copy_file(chef_resource)
		copy_type = chef_resource.chef_properties.where(:value_type => "copy_type").pluck(:value).first
		destination_file = chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first

		str_code = ""
		if copy_type == "file"
			des_path = File.dirname(destination_file)
			des_file_name = File.basename(destination_file)
			des_paths, des_last_path = get_path(des_path)

			str_code += "file '#{des_last_path}\/#{des_file_name}' do\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		elsif copy_type == "folder"
			des_paths, des_last_path = get_path(destination_file)

			str_code += "directory '#{des_last_path}' do\n"
			str_code += "  recursive true\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end

	def self.get_path(path)
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
		return str_temp, arr.last
	end


	def ResourceGenerator.create_file(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "created_file").pluck(:value).first

		src_path = File.dirname(value)
		src_file_name = File.basename(value)
		src_paths, src_last_path = get_path(src_path)

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "%w[ #{src_paths} ].each do |path|\n"
		str_code += "  directory path do\n"
		str_code += "    owner 'root'\n"
		str_code += "    group 'root'\n"
		str_code += "    mode '0777'\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "template '#{src_last_path}\/#{src_file_name}' do\n"
		str_code += "  source '#{src_file_name}.erb'\n"
		str_code += "  owner 'root'\n"
		str_code += "  group 'root'\n"
		str_code += "  mode '0755'\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_create_file(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "created_file").pluck(:value).first

		src_path = File.dirname(value)
		src_file_name = File.basename(value)
		src_paths, src_last_path = get_path(src_path)

		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "file '#{src_last_path}\/#{src_file_name}' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('#{src_last_path}\/#{src_file_name}') \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end


	def ResourceGenerator.move_file(chef_resource)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		destination_file = chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
		move_type = chef_resource.chef_properties.where(:value_type => "move_type").pluck(:value).first



		#des_path = File.dirname(destination_file)
		#des_file_name = File.basename(destination_file)
		des_paths, des_last_path = get_path(destination_file)

		str_code = ""
		str_code += "%w[ #{des_paths} ].each do |path|\n"
		str_code += "  directory path do\n"
		str_code += "    owner 'root'\n"
		str_code += "    group 'root'\n"
		str_code += "    mode '0755'\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		if move_type == "folder"
			src_paths, src_last_path = get_path(source_file)
			str_code += "if Dir.entries('#{des_last_path}').size == 2\n" # empty folder (have two links "." and ".." only)
			str_code += "  execute 'copy_all_file_in_folder' do\n"
			str_code += "    command 'mv  -v #{src_last_path}\/\* #{des_last_path}'\n"
			str_code += "  end\n"
			str_code += "end\n"
			str_code += "\n"
		elsif move_type == "file"
			src_path = File.dirname(source_file)
			src_file_name = File.basename(source_file)
			src_paths, src_last_path = get_path(src_path)
			str_code += "execute 'move_file' do\n"
			str_code += "  command 'mv #{src_last_path}\/#{src_file_name} #{des_last_path}\/'\n"
			str_code += "  not_if \{ \:\:File.exists?('#{des_last_path}\/#{src_file_name}') \}\n"
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end

	def ResourceGenerator.delete_move_file(chef_resource)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		destination_file = chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
		move_type = chef_resource.chef_properties.where(:value_type => "move_type").pluck(:value).first

		des_paths, des_last_path = get_path(destination_file)

		str_code = ""
		if move_type == "folder" # folder
			str_code += "directory '" + des_last_path + "' do\n"
			str_code += "  recursive true\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		elsif move_type == "file"
			src_file_name = File.basename(source_file)
			str_code += "file '#{des_last_path}\/#{src_file_name}' do\n"
			str_code += "  action :delete\n"
			str_code += "  only_if \{ ::File.exists?('#{des_last_path}\/#{src_file_name}') \}\n"
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end


	def ResourceGenerator.execute_command(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "execute_command").pluck(:value).first
		condition = chef_resource.chef_properties.where(:value_type => "condition").pluck(:value).first
		str_code = ""
		str_code += print_log(chef_resource.id)
		if condition == "alway"
			str_code += "execute 'execute_command' do\n"
			str_code += "  user 'root'\n"
			str_code += "  command '#{value}'\n"
			str_code += "end\n"
		elsif condition == "once"
			str_code += "execute 'execute_command' do\n"
			str_code += "  user 'root'\n"
			str_code += "  command '#{value}'\n"
			str_code += "  not_if { ::File.exists?('/var/lib/tomcat7/webapps/ROOT/execute_command/chef_resource_#{chef_resource.id}.txt') }\n"
			str_code += "end\n"
			str_code += "\n"
			str_code += "file '/var/lib/tomcat7/webapps/ROOT/execute_command/chef_resource_#{chef_resource.id}.txt' do\n"
			str_code += "  content ''\n"
			str_code += "  mode '0755'\n"
			str_code += "end\n"
		end
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_execute_command_file(chef_resource)
		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "file '/var/lib/tomcat7/webapps/ROOT/execute_command/chef_resource_#{chef_resource.id}.txt' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/execute_command/chef_resource_#{chef_resource.id}.txt') \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def ResourceGenerator.bash_script(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "bash_script").pluck(:value).first
		condition = chef_resource.chef_properties.where(:value_type => "condition").pluck(:value).first
		#bash = BashScript.find(value)
		str_code = ""
		str_code += print_log(chef_resource.id)
		str_code += "template '/tmp/#{value}.sh' do\n"
		str_code += "  source '#{value}.sh.erb'\n"
		str_code += "  owner 'root'\n"
		str_code += "  group 'root'\n"
		str_code += "  mode '0755'\n"
		str_code += "end\n"
		str_code += "\n"

		if condition == "alway"
			str_code += "execute 'execute_bash_script_#{value}' do\n"
			str_code += "  user 'root'\n"
			str_code += "  command 'bash /tmp/#{value}.sh'\n"
			str_code += "end\n"
			str_code += "\n"
			#str_code += "bash 'bash_script' do\n"
			#str_code += "  user 'root'\n"
			#str_code += "  code <<-EOH\n"
			#str_code += "  #{bash.bash_script_content}\n"
			#str_code += "  EOH\n"
			#str_code += "end\n"
		elsif condition == "once"
			#program_id = value.split("_").first
			#program = Program.find(program_id)
      if File.exists?("/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + value + ".sh.erb")
			  str_code += "execute 'execute_bash_script_#{value}' do\n"
			  str_code += "  user 'root'\n"
			  str_code += "  command 'bash /tmp/#{value}.sh'\n"
			  str_code += "  not_if { ::File.exists?('/var/lib/tomcat7/webapps/ROOT/bash_script/chef_resource_#{chef_resource.id}.txt') }\n"
			  str_code += "end\n"
			  str_code += "\n"
			  str_code += "file '/var/lib/tomcat7/webapps/ROOT/bash_script/chef_resource_#{chef_resource.id}.txt' do\n"
			  str_code += "  content ''\n"
			  str_code += "  mode '0755'\n"
			  str_code += "end\n"
			  str_code += "\n"
      end
			#str_code += "bash 'bash_script' do\n"
			#str_code += "  user 'root'\n"
			#str_code += "  code <<-EOH\n"
			#str_code += "  #{bash.bash_script_content}\n"
			#str_code += "  : > /var/lib/tomcat7/webapps/ROOT/bash_script/#{md5.hexdigest}.txt\n" #create empty text file
			#str_code += "  EOH\n"
			#str_code += "  not_if { ::File.exists?('/var/lib/tomcat7/webapps/ROOT/bash_script/#{md5.hexdigest}.txt') }\n"
			#str_code += "end\n"
		end
		#str_code += "\n"
		return str_code
	end

	def ResourceGenerator.delete_bash_script_file(chef_resource)
		value = chef_resource.chef_properties.where(:value_type => "bash_script").pluck(:value).first
		#condition = chef_resource.chef_properties.where(:value_type => "condition").pluck(:value).first

		#program_id = value.split("_").first
		#program = Program.find(program_id)
	  str_code = ""
		str_code += print_log(chef_resource.id)
	  str_code += "file '/tmp/#{value}.sh' do\n"
	  str_code += "  action :delete\n"
	  str_code += "  only_if \{ ::File.exists?('/tmp/#{value}.sh') \}\n"
	  str_code += "end\n"
	  str_code += "\n"
	  str_code += "file '/var/lib/tomcat7/webapps/ROOT/bash_script/chef_resource_#{chef_resource.id}.txt' do\n"
	  str_code += "  action :delete\n"
	  str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/bash_script/chef_resource_#{chef_resource.id}.txt') \}\n"
	  str_code += "end\n"
	  str_code += "\n"

		return str_code
	end

#########################################################################################################################


	def ResourceGenerator.remove_disuse_resource(remove_resource, program)
		@program = program
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
		elsif remove_resource.resource_type == "Copy_file"
			remove_copy_file(remove_resource)
		elsif remove_resource.resource_type == "Create_file"
			remove_create_file(remove_resource)
		elsif remove_resource.resource_type == "Config_file"
			remove_config_file(remove_resource)
		elsif remove_resource.resource_type == "Bash_script"
			remove_bash_script_file(remove_resource)
		elsif remove_resource.resource_type == "Execute_command"
			remove_execute_command_file(remove_resource)
		end
	end

	def self.remove_repository(remove_resource)
		program_name = remove_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "\%w\{#{program_name}\}.each do \|pkg\|\n"
		str_code += "  package pkg do\n"
		str_code += "    action :remove\n"
		str_code += "  end\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_deb(remove_resource)
		program_name = remove_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "dpkg_package '#{program_name}' do\n"
		str_code += "  action :remove\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_source(remove_resource)
		source_file = remove_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		program_name = remove_resource.chef_properties.where(:value_type => "program_name").pluck(:value).first
		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "bash 'uninstall_#{program_name}_from_source' do\n"
		str_code += "  user 'root'\n"
		str_code += "  cwd '#{source_file}'\n"
		str_code += "  code <<-EOH\n"
		str_code += "  sudo make uninstall\n"
		str_code += "  EOH\n"
		#str_code += "  only_if \{ Dir.exists?('#{source_file}') \}\n"
		str_code += "end\n"
		str_code += "\n"

		if remove_resource.status == "delete"
			str_code += "file '/var/lib/tomcat7/webapps/ROOT/install_from_source/chef_resource_#{remove_resource.id}.txt' do\n"
			str_code += "  action :delete\n"
			str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/install_from_source/chef_resource_#{remove_resource.id}.txt') \}\n"
			str_code += "end\n"
			str_code += "\n"
		end

		return str_code
	end

	def self.remove_download_file(remove_resource)
		source_file = remove_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		src_path = File.dirname(source_file)
		src_file_name = File.basename(source_file)
		src_paths, src_last_path = get_path(src_path)

		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "file '#{src_last_path}\/#{src_file_name}' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('#{src_last_path}\/#{src_file_name}') \}\n"
		str_code += "end\n"
		str_code += "\n"

		return str_code
	end

	def self.remove_extract_file(remove_resource)
		extract_to = remove_resource.chef_properties.where(:value_type => "extract_to").pluck(:value).first
		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "directory '#{extract_to}' do\n"
		str_code += "  recursive true\n"
		str_code += "  action :delete\n"
		str_code += "end\n"
		str_code += "\n"

		return str_code
	end

	def self.remove_config_file(remove_resource)
		config_file = remove_resource.chef_properties.where(:value_type => "config_file").pluck(:value).first
		file_name = File.basename(config_file)

		#program = Program.find(remove_resource.program_id)
		path_to_file = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".erb"
		File.delete(path_to_file) if File.exist?(path_to_file)

		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "file '/var/lib/tomcat7/webapps/ROOT/sharedfile/#{file_name}' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/sharedfile/#{file_name}') \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_copy_file(remove_resource)
		str_code = ""
		if remove_resource.value_type == "file"

			des_path = File.dirname(remove_resource.value)
			des_file_name = File.basename(remove_resource.value)
			des_paths, des_last_path = get_path(des_path)

			str_code += "file '#{des_last_path}\/#{des_file_name}' do\n"
			str_code += "  action :delete\n"
			str_code += "  only_if \{ ::File.exists?('#{des_last_path}\/#{des_file_name}') \}\n"
			str_code += "end\n"
			str_code += "\n"
		else
			des_paths, des_last_path = get_path(remove_resource.value)

			str_code += "directory '#{des_last_path}' do\n"
			str_code += "  recursive true\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end

	def self.remove_create_file(remove_resource)
		created_file = remove_resource.chef_properties.where(:value_type => "created_file").pluck(:value).first
		src_path = File.dirname(created_file)
		src_file_name = File.basename(created_file)
		src_paths, src_last_path = get_path(src_path)

		#program = Program.find(remove_resource.program_id)
		path_to_file = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + src_file_name + ".erb"
		File.delete(path_to_file) if File.exist?(path_to_file)

		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "file '#{src_last_path}\/#{src_file_name}' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('#{src_last_path}\/#{src_file_name}') \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.remove_move_file(remove_resource)
		chef_resource = ChefResource.find(remove_resource.chef_resource_id)
		source_file = chef_resource.chef_properties.where(:value_type => "source_file").pluck(:value).first
		destination_file = chef_resource.chef_properties.where(:value_type => "destination_file").pluck(:value).first
		move_type = chef_resource.chef_properties.where(:value_type => "move_type").pluck(:value).first

		des_paths, des_last_path = get_path(destination_file)

		str_code = ""
		if move_type == "folder" # folder
			str_code += "directory '" + des_last_path + "' do\n"
			str_code += "  recursive true\n"
			str_code += "  action :delete\n"
			str_code += "end\n"
			str_code += "\n"
		else # file
			src_file_name = File.basename(source_file)
			str_code += "file '#{des_last_path}\/#{src_file_name}' do\n"
			str_code += "  action :delete\n"
			str_code += "  only_if \{ ::File.exists?('#{des_last_path}\/#{src_file_name}') \}\n"
			str_code += "end\n"
			str_code += "\n"
		end
		return str_code
	end

	def self.remove_bash_script_file(remove_resource)
		#program = Program.find(remove_resource.program_id)
		file_name = @program.id.to_s + "_" + remove_resource.id.to_s

		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "file '/tmp/#{file_name}.sh' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('/tmp/#{file_name}.sh') \}\n"
		str_code += "end\n"
		str_code += "\n"
		str_code += "file '/var/lib/tomcat7/webapps/ROOT/bash_script/chef_resource_#{remove_resource.id}.txt' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/bash_script/chef_resource_#{remove_resource.id}.txt') \}\n"
		str_code += "end\n"
		str_code += "\n"

		path_to_file = "/home/ubuntu/chef-repo/cookbooks/" + @program.program_name + "/templates/" + file_name + ".sh.erb"
		File.delete(path_to_file) if File.exist?(path_to_file)

		return str_code
	end

	def self.remove_execute_command_file(remove_resource)
		str_code = ""
		str_code += print_log(remove_resource.id)
		str_code += "file '/var/lib/tomcat7/webapps/ROOT/execute_command/chef_resource_#{remove_resource.id}.txt' do\n"
		str_code += "  action :delete\n"
		str_code += "  only_if \{ ::File.exists?('/var/lib/tomcat7/webapps/ROOT/execute_command/chef_resource_#{remove_resource.id}.txt') \}\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

	def self.print_log(id)
		str_code = ""
		str_code += "log 'chef_resource=#{id}' do\n"
		str_code += "  action :nothing\n"
		str_code += "end\n"
		str_code += "\n"
		return str_code
	end

end
