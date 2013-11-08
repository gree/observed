require 'pathname'

require 'clockwork'
require 'observed/clockwork'

include Clockwork

# Below two lines are specific to Observed's Clockwork support.
# Others lines are just standard `clockwork.rb`
include Observed::Clockwork

the_dir = Pathname.new(File.dirname(__FILE__))

register_observed_handler :config_file => the_dir + 'observed.rb'

every(10.seconds, 'google.health')
