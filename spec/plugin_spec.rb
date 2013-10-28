require 'spec_helper'
require 'observed/input_plugin'

describe Observed::InputPlugin do

  before {
    %w| Foo Bar Baz |.each do |class_name|
      if Object.const_defined? class_name
        Object.send(:remove_const, class_name)
      end
      Observed::InputPlugin.instance_variable_set :@plugins, []
    end
  }

  describe 'attribute' do

    it 'can be given by constructor parameters' do
      Object.const_set(
          'Foo',
          Class.new(Observed::InputPlugin) do
            attribute :timeout_in_milliseconds
            attribute :number_of_trials
            attribute :check_name
          end
      )

      subject = Foo.new(
          :timeout_in_milliseconds => 5000,
          :number_of_trials => 5000,
          :check_name => 'check_name',
          :tag => 'tag'
      )

      expect(subject.timeout_in_milliseconds).to eq(5000)
      expect(subject.number_of_trials).to eq(5000)
      expect(subject.check_name).to eq('check_name')
      expect(subject.tag).to eq('tag')
    end

    it 'can have a default value' do
      Object.const_set(
          'Foo',
          Class.new(Observed::InputPlugin) do
            attribute :timeout_in_milliseconds
            attribute :number_of_trials
            attribute :check_name
            default :timeout_in_milliseconds => 5000
            default :number_of_trials => 5000
            default :check_name => 'check_name'
            default :tag => 'tag'
          end
      )

      subject = Foo.new

      expect(subject.timeout_in_milliseconds).to eq(5000)
      expect(subject.number_of_trials).to eq(5000)
      expect(subject.check_name).to eq('check_name')
      expect(subject.tag).to eq('tag')
    end

    context 'without a default value or a given value' do
      it 'raises errors when accessed' do
        Object.const_set(
            'Foo',
            Class.new(Observed::InputPlugin) do
              attribute :timeout_in_milliseconds
              attribute :number_of_trials
              attribute :check_name
            end
        )

        subject = Foo.new

        expect { subject.timeout_in_milliseconds }.to raise_error
        expect { subject.number_of_trials }.to raise_error
        expect { subject.check_name }.to raise_error
        expect { subject.tag }.to raise_error
      end
    end

  end

  describe '.plugins' do

    context 'with no plugins' do
      it 'returns an empty array' do
        expect(Observed::InputPlugin.plugins.size).to eq(0)
      end
    end

    context 'with a plugin' do
      before {
        Object.const_set(
          'Foo',
          Class.new(Observed::InputPlugin) do
            attribute :timeout_in_milliseconds
            attribute :number_of_trials
            attribute :check_name

            default :timeout_in_milliseconds => 5000
            default :number_of_trials => 2

            def sample
              time_to_sleep = rand
              sleep rand
              "Foo #{time_to_sleep}"
            end

            def self.plugin_name
              'foo'
            end
          end
        )
      }
      it 'returns an array with single element' do
        expect(Observed::InputPlugin.plugins).to eq([Foo])
      end
    end

    context 'with 2 plugins' do
      before {
        Object.const_set(
          'Bar',
          Class.new(Observed::InputPlugin) do
            ;
          end
        )
        Object.const_set(
          'Baz',
          Class.new(Observed::InputPlugin) do
              ;
          end
        )
      }
      it 'returns an array containing the plugins' do
        expect(Observed::InputPlugin.plugins).to eq([Bar, Baz])
      end
    end

  end

end
