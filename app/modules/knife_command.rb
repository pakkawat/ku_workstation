module KnifeCommand
	def KnifeCommand.run(command)
		require 'open3'
	    captured_stdout = ''
	    captured_stderr = ''
	    exit_status = Open3.popen3(ENV, command) {|stdin, stdout, stderr, wait_thr|
	      pid = wait_thr.pid # pid of the started process.
	      stdin.close
	      captured_stdout = stdout.read
	      captured_stderr = stderr.read
	      wait_thr.value # Process::Status object returned.
	    }
	    if captured_stdout == ""
	    	return false, error_message(captured_stderr)
	    else
	    	return true, ""
	    end
	end

	def self.error_message(msg)
		return msg
	end
end