#
# Install a signal handler to dump backtraces for all threads
#
# Trigger it with: kill -QUIT <pid>
#  
trap "QUIT" do
  fh = File.open("/tmp/xray_#$PID.trace", "a")
  if Kernel.respond_to? :caller_for_all_threads
    fh.puts "\n=============== XRay - Thread Dump of PID #$PID at #{Time.now.inspect} ==============="
    caller_for_all_threads.each_pair do |thread, stack|
      thread_description = thread.inspect
      thread_description << " [main]" if thread == Thread.main
      thread_description << " [current]" if thread == Thread.current
      thread_description << " alive=#{thread.alive?}"
      thread_description << " priority=#{thread.priority}"
      thread_separator = "-" * 78
      
      full_description = "\n#{thread_separator}\n"
      full_description << thread_description
      full_description << "\n#{thread_separator}\n"
      full_description << "    #{stack.join("\n      \\_ ")}\n"
      
      # Single puts to avoid interleaved output
      fh.puts full_description
    end
  else
    fh.puts "=============== XRay - Current Thread Backtrace ==============="
    fh.puts "Current thread : #{Thread.inspect}"
    fh.puts caller.join("\n    \\_ ")
  end
  fh.puts "\n=============== XRay - Done with PID #$PID ===============\n"
  fh.close
end
