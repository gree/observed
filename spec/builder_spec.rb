require 'spec_helper'
#require 'observed/builder'
require 'observed/configurable'

module Observed
  module KeyPathEncoding

    def at_key_path_on_hash(hash, key_path, options = {}, &block)
      create_if_missing = options[:create_if_missing]

      if create_if_missing.nil?
        fail "The key :create_if_missing must be exist in #{options}"
      end

      if hash.nil?
        fail 'The hash must not be nil'
      end

      first, *rest = case key_path
                     when Array
                       key_path
                     when String
                       key_path.split(".")
                     end
      key_str = first.to_s
      key_sym = first.intern
      key = if hash.key? key_str
              key_str
            else
              key_sym
            end
      if rest.empty?
        block.call hash, key
      else
        child = hash[key]
        if child
          at_key_path_on_hash(child, rest, options, &block)
        end
      end
    end
  end
end

module Observed
  class HashFetcher
    include Observed::KeyPathEncoding

    def initialize(hash)
      @hash = hash || fail('The hash must not be nil')
    end

    def [](key_path)
      at_key_path_on_hash @hash, key_path, create_if_missing: false do |h, k|
        h[k]
      end
    end
  end

  class HashBuilder
    include Observed::KeyPathEncoding

    def initialize(defaults={})
      @hash = defaults.dup
    end

    def []=(key_path, value)
      at_key_path_on_hash @hash, key_path, create_if_missing: true do |h, k|
        h[k] = value
      end
    end

    def build
      @hash
    end
  end

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
    attribute :adapter_plugins
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
      reporters << Observed::Reporter.new.configure(tag_pattern: tag_pattern, writer: writer, system: system)
    end

    def observe(tag, args)
      reader = read(args)
      observers << Observed::Observer.new.configure(tag: tag, reader: reader, system: system)
    end

    def write(args)
      to = args[:to]
      with = args[:with]
      writers << writer = case to
                 when String
                   writer_plugins[to].new(with)
                 when Observed::Writer
                   to
                 else
                   fail "Unexpected type of value for the key :to in: #{args}"
                 end
      writer
    end

    def read(args)
      from = args[:from]
      with = args[:with]
      readers << reader = case from
                 when String
                   reader_plugins[from].new(with)
                 when Observed::Reader
                   from
                 else
                   fail "Unexpected type of value for the key :from in: #{args}"
                 end
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

  class Writer
    include Observed::Configurable
    def write(tag, time, data)
      fail 'Not Implemented'
    end
  end

  class Reader
    include Observed::Configurable
    def read
      fail 'Not Implemented'
    end
  end

  class Translator
    include Observed::Configurable
    def translate(data)
      fail 'Not Implemented'
    end
  end

  class ReadAdapter
    include Observed::Configurable
    attribute :translator
    attribute :reader
    def read
      data = reader.read
      translator.translate(data)
    end
  end

  class WriteTranslator
    include Observed::Configurable
    attribute :translator
    attribute :writer
    def write(tag, time, data)
      writer.write tag, time, translator.translate(data)
    end
  end

  class Observer
    include Observed::Configurable
    attribute :reader
    attribute :tag
    attribute :system
    def observe
      data = reader.read
      system.emit(tag, data)
    end
  end

  class Reporter
    include Observed::Configurable
    attribute :writer
    attribute :tag_pattern
    def match(tag)
      tag_pattern.match(tag)
    end
    def report(tag, time, data)
      writer.write tag, time, data
    end
  end
end

describe Observed::Builder do

  include FakeFS::SpecHelpers

  subject {
    Observed::Builder.new
  }

  before {
    subject.configure(
      writer_plugins: writer_plugins,
      reader_plugins: reader_plugins,
      adapter_plugins: adapter_plugins,
      system: system
    )
  }

  let(:system) {
    mock('system')
  }

  let(:adapter_plugins) {
    transform = Class.new(Observed::Translator) do
      attribute :transform
      def translate(data)
        transform.call data, Observed::HashFetcher.new(data), Observed::HashBuilder.new({})
      end
    end
    { 'transform' => transform }
  }

  let(:writer_plugins) {
    stdout = Class.new(Observed::Writer) do
      attribute :format
      def write(tag, time, data)
        text = format.call tag, time, data, Observed::HashFetcher.new(data)
        STDOUT.puts text
      end
    end
    { 'stdout' => stdout }
  }

  let(:reader_plugins) {
    file = Class.new(Observed::Reader) do
      attribute :path
      attribute :key
      def read
        content = File.open(path, 'r') do |f|
          f.read
        end
        { key => content }
      end
    end
    {
        'file' => file
    }
  }

  it 'creates writers' do
    time = Time.now
    subject.write to: 'stdout', with: {
      format: -> tag, time, data, d { "value:#{d['foo.bar']}" }
    }
    STDOUT.expects(:puts).with('value:123')
    expect { subject.build.writers.first.write('foo.bar', time, {foo:{bar:123}}) }.to_not raise_error
  end

  it 'creates readers' do
    subject.read from: 'file', with: {
      path: 'foo.txt',
      key: 'content'
    }
    File.open('foo.txt', 'w') do |f|
      f.write('file content')
    end
    expect(subject.build.readers.first.read).to eq({ 'content' => 'file content' })
  end

  it 'creates observers' do
    subject.observe 'foo.bar', from: 'file', with: {
      path: 'foo.txt',
      key: 'content'
    }
    File.open('foo.txt', 'w') do |f|
      f.write('file content')
    end
    system.expects(:emit).with('foo.bar', { 'content' => 'file content' })
    expect { subject.build.observers.first.observe }.to_not raise_error
  end

  it 'creates reporters' do
    tag = 'foo.bar'
    time = Time.now

    subject.report /foo\.bar/, to: 'stdout', with: {
      format: -> tag, time, data, d { "foo.bar #{time} #{d[tag]}" }
    }
    reporter = subject.reporters.first
    STDOUT.expects(:puts).with("foo.bar #{time} 123").once
    expect(reporter.match(tag)).to be_true
    expect { reporter.report(tag, time, { foo: { bar: 123 }}) }.to_not raise_error
  end
end
