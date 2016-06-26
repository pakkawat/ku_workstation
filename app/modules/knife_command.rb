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
                        chef_resource = ChefResource.find(id)
			user.user_errors.create(chef_resource: chef_resource, line_number: line_number, log_path: log_path)
		else # "personal_chef_resource="
                        personal_chef_resource = PersonalChefResource.find(id)
			user.user_errors.create(personal_chef_resource: personal_chef_resource, line_number: line_number, log_path: log_path)
		end
	end

end
