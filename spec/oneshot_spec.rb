require 'spec_helper'

require 'observed/application/oneshot'

describe Observed::Application::Oneshot do
  let(:bar) {
    Class.new(Observed::Observer) do
      def observe
        sleep rand
        'Bar'
      end

      plugin_name 'oneshot_spec_bar'
    end
  }
  before {
    bar
  }
  #context 'with Hash objects' do
  #  subject {
  #    Observed::Application::Oneshot.create(:config => config)
  #  }
  #  let(:config) {
  #    {
  #        'observers' => {
  #          'test' => {
  #              plugin: 'oneshot_spec_bar',
  #              method: 'get',
  #              url: 'http://localhost:3000'
  #          }
  #        },
  #        'reporters' => {
  #          'test.*' => {
  #              plugin: 'stdout'
  #          }
  #        }
  #    }
  #  }
  #  it 'initializes' do
  #    expect(subject.run.size).not_to eq(0)
  #  end
  #end
  context 'with configuration files' do
    context 'with the correct plugins directory' do
      subject {
        Observed::Application::Oneshot.create(
            config_file: 'spec/fixtures/configure_by_conf/observed.conf'
        )
      }
      it 'initializes' do
        expect(subject.run.size).not_to eq(0)
      end
    end
  end
  describe '#parse_argv!' do
    it 'parses ARGV like arrays and extracts Hash objects containing initialization parameters' do
      argv = %w| -l logfile -d observed.rb foo1 |
      params = Observed::Application::Oneshot.parse_argv! argv
      expect(params).to eq({log_file: Pathname.new('logfile'), debug: true, config_file: 'observed.rb'})
      expect(argv).to eq(%w| foo1 |)
    end
  end
end
