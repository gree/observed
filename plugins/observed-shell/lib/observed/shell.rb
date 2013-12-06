require 'mixlib/shellout'

require 'observed/observer'
require 'observed/reporter'

module Observed
  module Plugins
  end
end

class Observed::Plugins::ShellObserver < Observed::Observer
  plugin_name 'shell'

  attribute :command

  def observe
    c = Mixlib::ShellOut.new(*command)
    c.run_command
    { command: command, stdout: c.stdout, stderr: c.stderr }
  end
end

class Observed::Plugins::ShellReporter < Observed::Reporter
  plugin_name 'shell'

  attribute :command
  attribute :input_key

  def report(data, options)
    if command.is_a? Proc
      num_params = command.parameters.size
      args = [data, options].take(num_params)
      result = command.call *args
      command_line = result
    else
      command_line = command
    end
    c = Mixlib::ShellOut.new(*command_line, input: data[get_attribute_value(:input_key)])
    c.run_command
    #logger.debug %Q|[observed-shell] ShellReporter executed the command "#{command_line}", captured stdout is "#{c.stdout}", captured stderr is #{c.stderr}"|
    data
  end
end

if __FILE__ == $0
  require 'observed'
  
  include Observed

  test = (observe via: 'shell', with: { command: 'echo foo' } )
    .then(report via: 'shell', with: { command: -> d { "growlnotify -m #{d[:stdout]}" } } )
  
  test.now
end
