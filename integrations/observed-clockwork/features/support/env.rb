$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'aruba/cucumber'

World(Aruba::Api)

Before do
  @aruba_timeout_seconds = 20
end
