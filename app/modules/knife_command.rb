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
		return check_error
	end

end
