APP_PATH = "/home/admin/bastion"

worker_processes 4
working_directory APP_PATH
listen "/tmp/admin.sock"
pid APP_PATH + "/tmp/pids/unicorn.pid"
stderr_path APP_PATH + "/log/unicorn.stderr.log"
stdout_path APP_PATH + "/log/unicorn.stdout.log"

preload_app true

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
          old_pid = "#{server.config[:pid]}.oldbin"
                  if old_pid != server.pid
                                begin
                                        sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
                                        Process.kill(sig, File.read(old_pid).to_i)
                          rescue Errno::ENOENT, Errno::ESRCH
                          end
                  end
        end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
