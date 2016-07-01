module KnifeCommand

	class ColourBlind
		  def initialize(*targets)
			@targets = targets
		  end

		  def write(*args)
		    @targets.each {|t| t.write(*args.map {|x| x.gsub(/\e\[(\d+)(;\d+)*m/, '')}.compact)}
		  end

		  def close
		    @targets.each(&:close)
		  end
	end

	def KnifeCommand.run(command, user)
		require 'logger'
		require 'open3'
		check_error = true
		log_path = ""
		user.nil? ? (log_path = "#{Rails.root}/log/knife/system.log") : (log_path = "#{Rails.root}/log/knife/#{user.ku_id}.log")
		file = ColourBlind.new(File.open(log_path, "a"))
		log = Logger.new(file)
		log.formatter = proc do |severity, datetime, progname, msg|
			"#{msg}\n"
		end
		log.info("-------------------- Start  #{Time.now.strftime('%c')}  --------------------\n")
    log.info(command+"\n")
		Open3.popen2e(command) do |stdin, stdout_err, wait_thr|
			while line=stdout_err.gets do
				log.info(line)
			end

			if wait_thr.value.success?
				user.log.update(error: false) if !user.nil?
				check_error = true
			else
				user.log.update(error: true) if !user.nil?
				check_error = false
			end
		end
		log.info("------------------------------------ End ---------------------------------------\n\n")
		log.close
		if check_error == false && !user.nil?
			create_user_errors(user, log_path)
		end
		return check_error
	end

	def KnifeCommand.create_empty_log(users)
		users.each do |user|
			File.open("#{Rails.root}/log/knife/#{user.ku_id}.log", "w") {}
		end
	end

	def self.create_user_errors(user, log_path)
		line_number = 0
		text = File.read(log_path)
		str_temp = ""

		text.lines.grep(/(personal_)?chef_resource=[0-9]*/){|x| line_number = text.lines.find_index(x)+1; str_temp = x;}
		str_temp = str_temp[/(personal_)?chef_resource=[0-9]*/]
		id = str_temp[/\d+/]
		chef = str_temp[/\D+/]
    line_number = text.lines.count - line_number

		if chef == "chef_resource="
			user.create_user_error(:chef_resource_id => id, :line_number => line_number, :log_path => log_path)
			chef_resource = ChefResource.find(id)
			create_user_error_msg(user, chef_resource, line_number, log_path)
		else # "personal_chef_resource="
			user.create_user_error(:personal_chef_resource_id => id, :line_number => line_number, :log_path => log_path)
			personal_chef_resource = PersonalChefResource.find(id)
			create_user_error_msg(user, personal_chef_resource, line_number, log_path)
		end
	end

	def self.create_user_error_msg(user, chef, line_number, log_path)
		error_msg = nil
		text = `tail -n #{line_number} #{log_path}`
		text = text.split("\n")
		case chef.resource_type
		when "Repository"
			error_msg = get_error_msg_repository(text)
		when "Deb"
			error_msg = get_error_msg_deb(text)
		when "Source"
			error_msg = get_error_msg_source(text)
		#when "Download"
			#error_msg = get_error_msg_download
		when "Extract"
			error_msg = get_error_msg_extract(text)
		when "Execute_command"
			error_msg = get_error_msg_execute_command(text)
		end
		user.user_error.update_attribute(:error_message,error_msg)
	end

	def self.get_error_msg_repository(text)
		return text[2]
	end

	def self.get_error_msg_deb(text)
		array_msg = text.grep(/source file\(s\) do not exist/)
		if array_msg.any?
			return array_msg.first.split(' ', 2).last
		else
			array_msg = text.grep(/dependency problems prevent configuration of/)
			if array_msg.any?
				return array_msg.first.split(' ', 2).last
			else
				array_msg = text.grep(/STDERR\: E\: Unmet dependencies\./)
				if array_msg.any?
					return array_msg.first.split(' ', 2).last
				else
					return nil
				end
			end
		end
	end

	def self.get_error_msg_source(text)
		array_msg = text.grep(/No such file or directory \@ dir_initialize/)
		if array_msg.any?
			return array_msg.first.split(' ', 2).last
		else
			array_msg = text.grep(/\.\/configure: No such file or directory|make: \*\*\* No targets specified and no makefile found|make: \*\*\* No rule to make target \`install\'/)
			if array_msg.any?
				new_array = Array.new
				array_msg.each do |msg|
					new_array.push(msg.split(' ', 2).last)
				end
				temp = ""
				new_array.uniq.each do |msg|
					temp = temp + msg + "\n"
				end
				return temp
			else
				return nil
			end
		end
	end

	def self.get_error_msg_extract(text)
		array_msg = text.grep(/No such file or directory/)
		if array_msg.any?
			return array_msg.first.split(' ', 2).last
		else
			array_msg = text.grep(/This does not look like a tar archive/)
			if array_msg.any?
				return array_msg.first.split(' ', 2).last
			else
				return nil
			end
		end
	end

	def self.get_error_msg_execute_command(text)
		array_msg = text.grep(/unrecognized service/)
		if array_msg.any?
			return array_msg.first.split(' ', 2).last
		else
			array_msg = text.grep(/No such file or directory/)
			if array_msg.any?
				return array_msg.first.split(' ', 2).last
			else
				return nil
			end
		end
	end

end
