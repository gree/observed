require 'spec_helper'

require 'observed/application/oneshot'

module OneshotSpec
  class BarPlugin < Observed::Plugin
    default :timeout_in_milliseconds => 5000
    default :number_of_trials => 10

    def run_health_check_once
      sleep rand
      "Bar"
    end

    def self.plugin_name
      'bar'
    end
  end
end

describe Observed::Application::Oneshot do
  context 'with Hash objects' do
    subject {
      Observed::Application::Oneshot.create(:config => config)
    }
    let(:config) {
      {
          'test' => {
              :plugin => 'bar',
              :method => 'get',
              :url => 'http://localhost:3000'
          }
      }
    }
    it 'initializes' do
      expect(subject.run.first.average_elapsed_time).not_to eq(0)
    end
  end
  context 'with configuration files' do
    context 'with the correct plugins directory' do
      subject {
        Observed::Application::Oneshot.create(
            :config_file => 'spec/fixtures/configure_by_conf/observed.conf',
            :plugins_directory => 'spec/fixtures/configure_by_conf'
        )
      }
      it 'initializes' do
        expect(subject.run.first.average_elapsed_time).not_to eq(0)
      end
    end
    context 'with an incorrect plugins directory' do
      subject {
        Observed::Application::Oneshot.create(
            :config_file => 'spec/fixtures/configure_by_conf/observed.conf'
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
