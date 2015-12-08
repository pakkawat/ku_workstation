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
		user.present ? (log_path = "#{RAILS_ROOT}/log/knife/system.log") : (log_path = "#{RAILS_ROOT}/log/knife/#{user.ku_id}.log")
		file = ColourBlind.new(File.open(log_path, "a"))
		log = Logger.new(file)
		log.formatter = proc do |severity, datetime, progname, msg|
			"#{datetime}: #{msg}\n"
		end

		Open3.popen3(command) do |stdin, stdout_err, wait_thr|
			while line=stdout_err.gets do
				log.info(line)
			end
			if wait_thr.value.success?
				check_error = true
			else
				check_error = false
			end
		end
		log.close
		return check_error
	end

end