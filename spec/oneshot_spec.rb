require 'spec_helper'

require 'observed/application/oneshot'

describe Observed::Application::Oneshot do
  before {
    %w| BarPlugin |.each do |class_name|
      if Object.const_defined? class_name
        Object.send(:remove_const, class_name)
      end
      Observed::Observer.instance_variable_set :@plugins, []
      Object.const_set(
          'BarPlugin',
          Class.new(Observed::Observer) do
            def observe
              sleep rand
              'Bar'
            end

            def self.plugin_name
              'bar'
            end
          end
      )
    end
  }
  context 'with Hash objects' do
    subject {
      Observed::Application::Oneshot.create(:config => config)
    }
    let(:config) {
      {
          'inputs' => {
            'test' => {
                plugin: 'bar',
                method: 'get',
                url: 'http://localhost:3000'
            }
          },
          'outputs' => {
            'test.*' => {
                plugin: 'stdout'
            }
          }
      }
    }
    it 'initializes' do
      expect(subject.run.size).not_to eq(0)
    end
  end
  context 'with configuration files' do
    context 'with the correct plugins directory' do
      subject {
        Observed::Application::Oneshot.create(
            config_file: 'spec/fixtures/configure_by_conf/observed.conf',
            plugins_directory: 'spec/fixtures/configure_by_conf'
        )
      }
      it 'initializes' do
        expect(subject.run.size).not_to eq(0)
      end
    end
    context 'with an incorrect plugins directory' do
      subject {
        Observed::Application::Oneshot.create(
            config_file: 'spec/fixtures/configure_by_conf/observed.conf'
        )
      }
      it 'raises an error on initialize' do
        expect { subject }.to raise_error
      end
    end
  end
  context 'with configuration directories' do

  end
end
