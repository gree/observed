require 'observed'
require 'observed/eventmachine'

include Observed

# This is a observed-eventmachine specific code to extend the DSL to use EventMachine
extend Observed::EM

class Test < Observed::Observer
  plugin_name 'test'
  def observe
    puts "Sleeping 10 seconds"
    sleep 10.0
    puts "Slept 10 seconds"
    [tag, {foo:1}]
  end
end

observe 'foo', via: 'test'

report /foo/, via: 'stdout', with: {
  format: -> _, _, data { "#{data}" }
}

# This is a observed-eventmachine specific code to schedule the observation on 'foo'
every 1, run: 'foo'

# This is a observed-eventmachine specific code to start running observations periodically, until we stop that by
# sending signals
start
