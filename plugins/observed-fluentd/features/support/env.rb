$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'aruba/cucumber'

World(Aruba::Api)

Before do
  @aruba_timeout_seconds = 120
end

When /^I run the command "([^"]+)"$/ do |cmd|
  system cmd
end

When /^I start my daemon with "([^"]*)"$/ do |cmd|
  @root = Pathname.new(File.dirname(__FILE__)).parent.parent.expand_path
  command = "#{@root.join('bin')}/#{cmd}"

  puts "In the working directory: #{Dir.pwd}"
  puts "Running #{command}"

  @pipe = IO.popen(command, "r")
  sleep 2 # so the daemon has a chance to boot

  # clean up the daemon when the tests finish
  at_exit do
    Process.kill("KILL", @pipe.pid)
  end
end

Then /^a daemon called "([^"]*)" should be running$/ do |daemon|
  `ps -eo command |grep #{daemon}`.size.should > 0
end
