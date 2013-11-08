require 'clockwork'
require 'observed/clockwork'

include Clockwork
include Observed::Clockwork

observed :config_file => 'observed.conf'

every(10.seconds, 'foo_1')
