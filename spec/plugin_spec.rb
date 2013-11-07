require 'spec_helper'
require 'observed/observer'

describe Observed::Observer do

  before {
    %w| Foo Bar Baz |.each do |class_name|
      if Object.const_defined? class_name
        Object.send(:remove_const, class_name)
      end
      Observed::Observer.instance_variable_set :@plugins, []
    end
  }

  describe 'attribute' do

    it 'can be given by constructor parameters' do
      Object.const_set(
          'Foo',
          Class.new(Observed::Observer) do
            attribute :timeout_in_milliseconds
            attribute :number_of_trials
          end
      )

      subject = Foo.new(
          timeout_in_milliseconds: 5000,
          number_of_trials: 5000,
          tag: 'tag'
      )

      expect(subject.timeout_in_milliseconds).to eq(5000)
      expect(subject.number_of_trials).to eq(5000)
      expect(subject.tag).to eq('tag')
    end

    it 'can have a default value' do
      Object.const_set(
          'Foo',
          Class.new(Observed::Observer) do
            attribute :timeout_in_milliseconds
            attribute :number_of_trials
            default :timeout_in_milliseconds => 5000
            default :number_of_trials => 5000
            default :tag => 'tag'
          end
      )

      subject = Foo.new

      expect(subject.timeout_in_milliseconds).to eq(5000)
      expect(subject.number_of_trials).to eq(5000)
      expect(subject.tag).to eq('tag')
    end

    context 'without a default value or a given value' do
      it 'raises errors when accessed' do
        Object.const_set(
            'Foo',
            Class.new(Observed::Observer) do
              attribute :timeout_in_milliseconds
              attribute :number_of_trials
            end
        )

        subject = Foo.new

        expect { subject.timeout_in_milliseconds }.to raise_error
        expect { subject.number_of_trials }.to raise_error
        expect { subject.tag }.to raise_error
      end
    end

  end

  describe '.find_plugin_named' do

    it 'returns nil when no plugin with the specific name found' do
      expect(Observed::Observer.find_plugin_named('an_invalid_name')).to be_nil
    end

    context 'with a plugin' do
      before {
        Object.const_set(
          'Foo',
          Class.new(Observed::Observer) do
            attribute :timeout_in_milliseconds
            attribute :number_of_trials

            default :timeout_in_milliseconds => 5000
            default :number_of_trials => 2

            def sample
              time_to_sleep = rand / 100
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
        expect(Observed::Observer.find_plugin_named('foo')).to eq(Foo)
      end
    end

    context 'with 2 plugins' do
      before {
        Object.const_set(
          'Bar',
          Class.new(Observed::Observer) do
            plugin_name 'bar'
          end
        )
        Object.const_set(
          'Baz',
          Class.new(Observed::Observer) do
            plugin_name 'baz'
          end
        )
      }
      it 'returns an array containing the plugins' do
        expect(Observed::Observer.find_plugin_named('bar')).to eq(Bar)
        expect(Observed::Observer.find_plugin_named('baz')).to eq(Baz)
      end
    end

  end

end
