require 'spec_helper'
require 'observed/config_builder'

describe Observed::ConfigBuilder do

  include FakeFS::SpecHelpers

  subject {
    Observed::ConfigBuilder.new(
        writer_plugins: writer_plugins,
        reader_plugins: reader_plugins,
        observer_plugins: observer_plugins,
        reporter_plugins: reporter_plugins,
        translator_plugins: translator_plugins,
        system: system
    )
  }

  let(:system) {
    mock('system')
  }

  let(:observer_plugins) {
    my_file = Class.new(Observed::Observer) do
      attribute :path
      attribute :key
      def observe
        content = File.open(path, 'r') do |f|
          f.read
        end
        system.report(tag, { key => content })
      end
    end
    { 'my_file' => my_file }
  }

  let(:reporter_plugins) {
    my_stdout = Class.new(Observed::Reporter) do
      attribute :format
      def match(tag)
        true
      end
      def report(tag, time, data)
        text = format.call tag, time, data, Observed::Hash::Fetcher.new(data)
        STDOUT.puts text
      end
    end
    { 'my_stdout' => my_stdout }
  }

  let(:writer_plugins) {
    stdout = Class.new(Observed::Writer) do
      attribute :format
      def write(tag, time, data)
        text = format.call tag, time, data, Observed::Hash::Fetcher.new(data)
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
  let(:translator_plugins) {
    my_translator = Class.new(Observed::Translator) do
      attribute :tag
      attribute :format
      def translate(tag, time, data)
        formatted_data = format.call tag, time, data, Observed::Hash::Fetcher.new(data), Observed::Hash::Builder.new
        {formatted:formatted_data}
      end
      plugin_name 'my_translator'
    end
    {
        'my_translator' => my_translator
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

  it 'creates observers from reader plugins' do
    subject.observe 'foo.bar', from: 'file', with: {
      path: 'foo.txt',
      key: 'content'
    }
    File.open('foo.txt', 'w') do |f|
      f.write('file content')
    end
    system.expects(:report).with('foo.bar', { 'content' => 'file content' })
    expect { subject.build.observers.first.observe }.to_not raise_error
  end

  it 'creates observers from observer plugins' do
    subject.observe 'foo.bar', via: 'my_file', which: {
        path: 'foo.txt',
        key: 'content'
    }
    File.open('foo.txt', 'w') do |f|
      f.write('file content')
    end
    system.expects(:report).with('foo.bar', { 'content' => 'file content' })
    expect { subject.build.observers.first.observe }.to_not raise_error
  end

  #it 'creates default observers from poller plugins' do
  #  subject.observe 'foo.bar', via: 'poll', which: {
  #      result: 'result'
  #  }
  #  system.expects(:report).with('foo.bar', { 'content' => 'file content' })
  #  expect { subject.build.pollers.first.poll }.to_not raise_error
  #end

  it 'creates reporters from writer plugins' do
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

  it 'creates reporters from reporter plugins' do
    tag = 'foo.bar'
    time = Time.now

    subject.report /foo\.bar/, via: 'my_stdout', with: {
        format: -> tag, time, data, d { "foo.bar #{time} #{d[tag]}" }
    }
    reporter = subject.reporters.first
    STDOUT.expects(:puts).with("foo.bar #{time} 123").once
    expect(reporter.match(tag)).to be_true
    expect { reporter.report(tag, time, { foo: { bar: 123 }}) }.to_not raise_error
  end

  it 'creates translator from translator plugins' do
    time = Time.now
    translator = subject.translate /foo\.bar/, via: 'my_translator', with: {
      tag: 'foo.baz',
      format: -> tag, time, data, f, b { b['bar.baz'] = "foo.bar #{time} #{f[tag]}"; b.build }
    }

    result = {bar:{baz:"foo.bar #{time} 123"}}

    translator.now({foo:{bar: 123}}, {tag: 'foo.bar', time: time}) do |data, options|
      expect(data).to eq({formatted: result})
    end
  end
end
