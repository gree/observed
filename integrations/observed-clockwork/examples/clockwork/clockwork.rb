require 'clockwork'
require 'observed/clockwork'

include Clockwork
include Observed::Clockwork

register_observed_handler :config_file => File.dirname(__FILE__) + '/observed.conf'

every(10.seconds, 'foo_1')
