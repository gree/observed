require 'logger'

require 'observed/config'
require 'observed/configurable'
require 'observed/default'
require 'observed/hash'
require 'observed/translator'
require 'observed/execution_job_factory'

module Observed

  class ProcObserver < Observed::Observer
    def initialize(&block)
      @block = block
    end
    def observe(data=nil, options=nil)
      @block.call data, options
    end
  end

  class ProcTranslator < Observed::Translator
    def initialize(&block)
      @block = block
    end
    def translate(tag, time, data)
      @block.call data, {tag: tag, time: time}
    end
  end

  class ProcReporter < Observed::Reporter
    def initialize(tag_pattern, &block)
      @tag_pattern = tag_pattern
      @block = block
    end
    def match(tag)
      tag.match(@tag_pattern) if tag && @tag_pattern
    end
    def report(tag, time, data)
      @block.call data, {tag: tag, time: time}
    end
  end

  class ConfigBuilder
    include Observed::Configurable

    attribute :logger, default: Logger.new(STDOUT, Logger::DEBUG)

    def initialize(args)
      @context = args[:context]
      @observer_plugins = args[:observer_plugins] if args[:observer_plugins]
      @reporter_plugins = args[:reporter_plugins] if args[:reporter_plugins]
      @translator_plugins = args[:translator_plugins] if args[:translator_plugins]
      @system = args[:system] || fail("The key :system must be in #{args}")
      configure args
    end

    def system
      @system
    end

    def observer_plugins
      @observer_plugins || select_named_plugins_of(Observed::Observer)
    end

    def reporter_plugins
      @reporter_plugins || select_named_plugins_of(Observed::Reporter)
    end

    def translator_plugins
      @translator_plugins || select_named_plugins_of(Observed::Translator)
    end

    def select_named_plugins_of(klass)
      plugins = {}
      klass.select_named_plugins.each do |plugin|
        plugins[plugin.plugin_name] = plugin
      end
      plugins
    end

    def build
      Observed::Config.new(
          observers: observers,
          reporters: reporters
      )
    end

    # @param [Regexp] tag_pattern The pattern to match tags added to data from observers
    # @param [Hash] args The configuration for each reporter which may or may not contain (1) which reporter plugin to
    # use or which writer plugin to use (in combination with the default reporter plugin) (2) initialization parameters
    # to instantiate the reporter/writer plugin
    def report(tag_pattern=nil, args={}, &block)
      if tag_pattern.is_a? ::Hash
        args = tag_pattern
        tag_pattern = nil
      end
      reporter = if args[:via] || args[:using]
                   via = args[:via] || args[:using]
                   with = args[:with] || args[:which] || {}
                   with = ({logger: @logger}).merge(with).merge({tag_pattern: tag_pattern, system: system})
                   plugin = reporter_plugins[via] ||
                       fail(RuntimeError, %Q|The reporter plugin named "#{via}" is not found in "#{reporter_plugins}"|)
                   plugin.new(with)
                 elsif block_given?
                   Observed::ProcReporter.new tag_pattern, &block
                 else
                   fail "Invalid combination of arguments: #{tag_pattern} #{args}"
                 end
      begin
        reporter.match('test')
      rescue => e
        fail "A mis-configured reporter plugin found: #{reporter}"
      rescue NotImplementedError => e
        builtin_methods = Object.methods
        info = (reporter.methods - builtin_methods).map {|sym| reporter.method(sym) }.map(&:source_location).compact
        fail "Incomplete reporter plugin found: #{reporter}, defined in: #{info}"
      end

      reporters << reporter
      report_it = convert_to_job(reporter)
      if tag_pattern
        receive(tag_pattern).then(report_it)
      end
      report_it
    end

    class ObserverCompatibilityAdapter < Observed::Observer
      include Observed::Configurable
      attribute :observer
      attribute :system
      attribute :tag

      def configure(args)
        super
        observer.configure(args)
      end

      def observe(data=nil, options=nil)
        case observer.method(:observe).parameters.size
          when 0
            observer.observe
          when 1
            observer.observe data
          when 2
            observer.observe data, options
        end
      end
    end

    # @param [String] tag The tag which is assigned to data which is generated from this observer, and is sent to
    # reporters later
    # @param [Hash] args The configuration for each observer which may or may not contain (1) which observer plugin to
    # use or which reader plugin to use (in combination with the default observer plugin) (2) initialization parameters
    # to instantiate the observer/reader plugin
    def observe(tag=nil, args={}, &block)
      if tag.is_a? ::Hash
        args = tag
        tag = nil
      end
      observer = if args[:via] || args[:using]
                   via = args[:via] || args[:using] ||
                       fail(RuntimeError, %Q|Missing observer plugin name for the tag "#{tag}" in "#{args}"|)
                   with = args[:with] || args[:which] || {}
                   plugin = observer_plugins[via] ||
                       fail(RuntimeError, %Q|The observer plugin named "#{via}" is not found in "#{observer_plugins}"|)
                   observer = plugin.new(({logger: logger}).merge(with).merge(tag: tag, system: system))
                   ObserverCompatibilityAdapter.new(
                     system: system,
                     observer: observer,
                     tag: tag
                   )
                 elsif block_given?
                   Observed::ProcObserver.new &block
                 else
                   fail "No args valid args (in args=#{args}) or a block given"
                 end
      observers << observer
      observe_that = convert_to_job(observer)
      if tag
        observe_that.then(emit(tag))
      else
        observe_that
      end
    end

    def translate(args={}, &block)
      translator = if args[:via] || args[:using]
                     #tag_pattern || fail("Tag pattern missing: #{tag_pattern} where args: #{args}")
                     via = args[:via] || args[:using]
                     with = args[:with] || args[:which] || {}
                     with = ({logger: logger}).merge(with).merge({system: system})
                     plugin = translator_plugins[via] ||
                         fail(RuntimeError, %Q|The reporter plugin named "#{via}" is not found in "#{translator_plugins}"|)
                     plugin.new(with)
                   else
                     Observed::ProcTranslator.new &block
                 end
      convert_to_job(translator)
    end

    def emit(tag)
      @context.jobbed_event_bus.pipe_to_emit(tag)
    end

    def receive(pattern)
      @context.jobbed_event_bus.receive(pattern)
    end

    def reporters
      @reporters ||= []
    end

    def observers
      @observers ||= []
    end

    private

    def convert_to_job(underlying)
      @execution_job_factory ||= @context.execution_job_factory
      @execution_job_factory.convert_to_job(underlying)
    end
  end

end
