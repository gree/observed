require 'observed/configurable'
require 'observed/default_observer'
require 'observed/default_reporter'
require 'observed/hash_builder'
require 'observed/hash_fetcher'
require 'observed/reader'
require 'observed/writer'

module Observed

  class NewConfig
    include Observed::Configurable

    attribute :writers
    attribute :readers
    attribute :reporters
    attribute :observers
  end

  class Builder
    include Observed::Configurable

    attribute :writer_plugins
    attribute :reader_plugins
    attribute :reporter_plugins
    attribute :observer_plugins
    attribute :system

    def build
      NewConfig.new(
          writers: writers,
          readers: readers,
          observers: observers,
          reporters: reporters
      )
    end

    def report(tag_pattern, args)
      writer = write(args)
      reporter = if writer
                   Observed::DefaultReporter.new.configure(tag_pattern: tag_pattern, writer: writer, system: system)
                 else
                   via = args[:via] || args[:using]
                   with = args[:with] || args[:which]
                   reporter_plugins[via].new(with)
                 end
      reporters << reporter
    end

    def observe(tag, args)
      reader = read(args)
      observer = if reader
                   Observed::DefaultObserver.new.configure(tag: tag, reader: reader, system: system)
                 else
                   via = args[:via] || args[:using]
                   with = args[:with] || args[:which]
                   observer_plugins[via].new(with.merge(tag: tag, system: system))
                 end
      observers << observer
    end

    def write(args)
      to = args[:to]
      with = args[:with] || args[:which]
      writer = case to
               when String
                 writer_plugins[to].new(with)
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
                 reader_plugins[from].new(with)
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
