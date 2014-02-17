require 'jsonpath'
require 'ruby_gntp'

require 'observed/reporter'

module Observed
  module Plugins
  end
end

class Observed::Plugins::GrowlReporter < Observed::Reporter
  plugin_name 'growl'

  attribute :app_name
  attribute :title
  attribute :text
  attribute :icon
  attribute :app_name_path
  attribute :title_path
  attribute :text_path
  attribute :icon_path
  attribute :app_name_key, default: :app_name
  attribute :title_key, default: :title
  attribute :text_key, default: :text
  attribute :icon_key, default: :icon

  def report(data, options)
    fetch_by_key = Fetcher.new(self, data)
    fetch_by_path = JSONPathFetcher.new(self, data)
    GNTP.notify({
      :app_name => fetch_by_path[:app_name_path] || fetch_by_key[app_name_key] || '`app_name` not configured for observed-growl',
      :title    => fetch_by_path[:title_path] || fetch_by_key[title_key] || '`title` not configured for observed-growl',
      :text     => fetch_by_path[:text_path] || fetch_by_key[text_key] || '`text` not configured for observed-growl',
      :icon     => fetch_by_path[:icon_path] || fetch_by_key[icon_key] || ''
    })
    data
  end

  class JSONPathFetcher
    def initialize(reporter, data)
      @reporter = reporter
      @data = data
    end
    def [](name)
      path = @reporter.get_attribute_value(name)
      if path
        JsonPath.on(@data, path)
      end
    end
  end

  class Fetcher
    def initialize(reporter, data)
      @reporter = reporter
      @data = data
    end
    def [](name)
      @data[name] || @reporter.get_attribute_value(name)
    end
  end
end

if __FILE__ == $0
  require 'observed'

  include Observed

  class TestObserver < Observed::Observer
    plugin_name 'test'
  
    def observe
      {foo: 'foo from observer', 'bar' => { 'baz' => 'bar.baz from observer' } }
    end
  end

  test = (observe via: 'test')
    .then(report via: 'growl', with: { text_key: :foo, title_path: 'bar.baz' })

  test.now
end
