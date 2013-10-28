require 'spec_helper'
require 'observed'

describe Observed do
  include FakeFS::SpecHelpers

  context 'with `load!`' do

    subject do
      Observed.init!
      Observed.load!('observed.rb')
      Observed.config
    end

    context 'with invalid file path' do
      it 'should raise an error while loading' do
        expect { subject }.to raise_error('No such file or directory - observed.rb')
      end
    end

    context 'with valid file path' do
      before do
        Observed.init!
        File.open('./observed.rb', 'w') do |file|
          file.write(
  <<-EOS
  configure :plugins_directory => 'spec/fixtures/configure_by_conf'

  observe 'foo', { plugin: 'foo' }
  EOS
          )
        end
      end

      it 'should load observed.rb' do
        expect(subject.size).to eq(2)
      end
    end
  end

  context 'with `require`' do
    before {
      Observed.init!
      $LOAD_PATH.push 'spec/fixtures/configure_by_require'
      require 'observed_conf'
    }

    subject {
      Observed.config
    }

    it 'should load observed.rb' do
      expect(subject.size).to eq(2)
    end

  end

end
