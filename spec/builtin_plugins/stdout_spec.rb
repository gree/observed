require 'spec_helper'

require 'observed/builtin_plugins/stdout'

describe Observed::BuiltinPlugins::Stdout do

  subject {
    reporter = Observed::BuiltinPlugins::Stdout.new
    reporter.configure config
    reporter
  }

  let(:config) {
    { tag_pattern: /foo\..+/, format: formatter }
  }

  context 'with a specific formatter' do

    let(:formatter) {
      -> tag, time, data, fetcher { "foo #{time.to_i} #{data[:foo]} #{fetcher['bar.baz']}" }
    }

    it 'reports the formatted data to the stdout' do
      time = Time.now
      STDOUT.expects(:puts).with("foo #{time.to_i} 1 2")
      expect { subject.report('foo', time, {foo: 1, bar: {baz: 2}}) }.to_not raise_error
    end

  end

  context 'without a specific formatter' do

    let(:formatter) {
      nil
    }

    it 'reports the data formatted by the default formatter to the stdout' do
      time = Time.now
      STDOUT.expects(:puts).with("#{time.to_s} foo {:foo=>1}")
      expect { subject.report('foo', time, {foo: 1}) }.to_not raise_error
    end

  end

  context 'with the formatter whose number of parameters is not 3 nor 4' do

    let(:formatter) {
      -> a, b {}
    }

    it 'fails while reporting' do
      pattern = /Number of parameters for the function for the key :format must be 3 or 4, but was 2/
      expect { subject.report('foo', Time.now, {}) }.to raise_error(pattern)
    end
  end
end
