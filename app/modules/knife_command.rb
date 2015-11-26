module KnifeCommand
	def KnifeCommand.run(command)
		require 'open3'
	    #captured_stdout = ''
	    captured_stderr = ''
	    exit_status = Open3.popen3(ENV, command) {|stdin, stdout, stderr, wait_thr|
	      pid = wait_thr.pid # pid of the started process.
	      stdin.close
	      #captured_stdout = stdout.read
	      captured_stderr = stderr.read
	      exit_status = wait_thr.value # Process::Status object returned.
	    }
	    if exit_status.success?
	    	return true, ""
	    else
	    	return false, error_message(captured_stderr)
	    end
	end

	def self.error_message(msg)
		return msg
	end
end