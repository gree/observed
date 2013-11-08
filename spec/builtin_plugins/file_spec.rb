require 'spec_helper'

require 'observed/builtin_plugins/file'

describe Observed::BuiltinPlugins::File do

  include FakeFS::SpecHelpers

  subject {
    reporter = Observed::BuiltinPlugins::File.new
    reporter.configure config
    reporter
  }

  let(:config) {
    { tag_pattern: /foo\..+/, format: formatter, path: path }
  }

  let(:path) {
    'test.txt'
  }

  before(:each) {
    File.open(path, 'w') do |f|
      f.write("default content\n")
    end
  }

  shared_examples_for 'the plugin in the appending mode' do

    context 'with a specific formatter' do

      let(:formatter) {
        -> tag, time, data, fetcher { "foo #{time.to_i} #{data[:foo]} #{fetcher['bar.baz']}" }
      }

      it 'reports the formatted data to the file' do
        time = Time.now

        expect { subject.report('foo', time, {foo: 1, bar: {baz: 2}}) }.to_not raise_error

        expect(File.read(path)).to eq("default content\nfoo #{time.to_i} 1 2\n")
      end

    end

    context 'without a specific formatter' do

      let(:formatter) {
        nil
      }

      it 'reports the data formatted by the default formatter to the stdout' do
        time = Time.now

        expect { subject.report('foo', time, {foo: 1}) }.to_not raise_error

        expect(File.read(path)).to eq("default content\n#{time.to_s} foo {:foo=>1}\n")
      end

    end
  end

  shared_examples_for 'the plugin in the overwriting mode' do

    context 'with a specific formatter' do

      let(:formatter) {
        -> tag, time, data, fetcher { "foo #{time.to_i} #{data[:foo]} #{fetcher['bar.baz']}" }
      }

      it 'reports the formatted data to the file' do
        time = Time.now

        expect { subject.report('foo', time, {foo: 1, bar: {baz: 2}}) }.to_not raise_error

        expect(File.read(path)).to eq("foo #{time.to_i} 1 2\n")
      end

    end

    context 'without a specific formatter' do

      let(:formatter) {
        nil
      }

      it 'reports the data formatted by the default formatter to the stdout' do
        time = Time.now

        expect { subject.report('foo', time, {foo: 1}) }.to_not raise_error

        expect(File.read(path)).to eq("#{time.to_s} foo {:foo=>1}\n")
      end

    end

  end

  context 'with the default mode' do

    it_behaves_like 'the plugin in the appending mode'

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

  context 'with the mode :append' do
    before {
      subject.configure mode: :append
    }
    it_behaves_like 'the plugin in the appending mode'
  end

  context 'with the mode \'a\'' do
    before {
      subject.configure mode: 'a'
    }
    it_behaves_like 'the plugin in the appending mode'
  end

  context 'with the mode :overwrite' do
    before {
      subject.configure mode: :overwrite
    }
    it_behaves_like 'the plugin in the overwriting mode'
  end

  context 'with the mode \'w\'' do
    before {
      subject.configure mode: 'w'
    }
    it_behaves_like 'the plugin in the overwriting mode'
  end
end
