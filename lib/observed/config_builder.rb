require 'observed/config'
require 'observed/configurable'
require 'observed/default'
require 'observed/hash'
require 'observed/reader'
require 'observed/writer'

module Observed

  class ConfigBuilder
    include Observed::Configurable

    def initialize(args)
      @writer_plugins = args[:writer_plugins] if args[:writer_plugins]
      @reader_plugins = args[:reader_plugins] if args[:reader_plugins]
      @observer_plugins = args[:observer_plugins] if args[:observer_plugins]
      @reporter_plugins = args[:reporter_plugins] if args[:reporter_plugins]
      @system = args[:system] || fail("The key :system must be in #{args}")
    end

    def system
      @system
    end

    def writer_plugins
      @writer_plugins || select_named_plugins_of(Observed::Writer)
    end

    def reader_plugins
      @reader_plugins || select_named_plugins_of(Observed::Reader)
    end

    def observer_plugins
      @observer_plugins || select_named_plugins_of(Observed::Observer)
    end

    def reporter_plugins
      @reporter_plugins || select_named_plugins_of(Observed::Reporter)
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
          writers: writers,
          readers: readers,
          observers: observers,
          reporters: reporters
      )
    end

    # @param [Regexp] tag_pattern The pattern to match tags added to data from observers
    # @param [Hash] args The configuration for each reporter which may or may not contain (1) which reporter plugin to
    # use or which writer plugin to use (in combination with the default reporter plugin) (2) initialization parameters
    # to instantiate the reporter/writer plugin
    def report(tag_pattern, args)
      writer = write(args)
      tag_pattern || fail("Tag pattern missing: #{tag_pattern} where args: #{args}")
      reporter = if writer
                   Observed::Default::Reporter.new.configure(tag_pattern: tag_pattern, writer: writer, system: system)
                 else
                   via = args[:via] || args[:using]
                   with = args[:with] || args[:which] || {}
                   with = with.merge({tag_pattern: tag_pattern})
                   plugin = reporter_plugins[via] ||
                       fail(RuntimeError, %Q|The reporter plugin named "#{via}" is not found in "#{reporter_plugins}"|)
                   plugin.new(with)
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
      reporter
    end

    # @param [String] tag The tag which is assigned to data which is generated from this observer, and is sent to
    # reporters later
    # @param [Hash] args The configuration for each observer which may or may not contain (1) which observer plugin to
    # use or which reader plugin to use (in combination with the default observer plugin) (2) initialization parameters
    # to instantiate the observer/reader plugin
    def observe(tag, args)
      reader = read(args)
      observer = if reader
                   Observed::Default::Observer.new.configure(tag: tag, reader: reader, system: system)
                 else
                   via = args[:via] || args[:using] ||
                       fail(RuntimeError, %Q|Missing observer plugin name for the tag "#{tag}" in "#{args}"|)
                   with = args[:with] || args[:which] || {}
                   plugin = observer_plugins[via] ||
                       fail(RuntimeError, %Q|The observer plugin named "#{via}" is not found in "#{observer_plugins}"|)
                   plugin.new(with.merge(tag: tag, system: system))
                 end
      observers << observer
      observer
    end

    def write(args)
      to = args[:to]
      with = args[:with] || args[:which]
      writer = case to
               when String
                 plugin = writer_plugins[to] ||
                     fail(RuntimeError, %Q|The writer plugin named "#{to}" is not found in "#{writer_plugins}"|)
                 plugin.new(with)
               when Observed::Writer
                 to
               when nil
                 nil
               else
                 fail "Unexpected type of value for the key :to in: #{args}"
               end
      writers << writer if writer
      writer
    end

    def read(args)
      from = args[:from]
      with = args[:with] || [:which]
      reader = case from
               when String
                 plugin = reader_plugins[from] || fail(RuntimeError, %Q|The reader plugin named "#{from}" is not found in "#{reader_plugins}"|)
                 plugin.new(with)
               when Observed::Reader
                 from
               when nil
                 nil
               else
                 fail "Unexpected type of value for the key :from in: #{args}"
               end
      readers << reader if reader
      reader
    end

    def writers
      @writers ||= []
    end

    def readers
      @readers ||= []
    end

    def reporters
      @reporters ||= []
    end

    def observers
      @observers ||= []
    end
  end

end
