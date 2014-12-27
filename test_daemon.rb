require 'active_support/all'
class TestDaemon
  def initialize
    @flag_int = false
    @pid_file = "./test_daemon.pid" 
    out_file  = "./test_daemon.txt" 
    @out_file = File.open(out_file, "w")
  end


  def run
    begin
      @out_file.puts "[START]"
      daemonize
      set_trap
      execute
      @out_file.puts "[E N D]"
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.run] #{e}"
      exit 1
    end
  end

  private

  def daemonize
    begin
      Process.daemon(true, true)
      open(@pid_file, 'w') {|f| f << Process.pid} if @pid_file
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.daemonize] #{e}"
      exit 1
    end
  end


  def set_trap
    begin
      Signal.trap(:INT)  {@flag_int = true}
      Signal.trap(:TERM) {@flag_int = true}
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.set_trap] #{e}"
      exit 1
    end
  end


  def execute
    begin
      count = 0
      loop do
        break if @flag_int
        sleep 1
        dummy = Time.now.change(hour: 4, min: 30)
        current_time =  Time.now
        @out_file.puts [dummy , current_time].join(",")
        @out_file.flush
      end
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.execute] #{e}"
      @out_file.close
      exit 1
    end
  end
end

obj_proc = TestDaemon.new
obj_proc.run

