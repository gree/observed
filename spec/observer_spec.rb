require 'spec_helper'
require 'observed/observer'

describe Observed::Observer do

  subject {
    described_class.new(tag: 'the_tag', system: sys)
  }

  let(:sys) { mock('system') }

  it 'fails when the method `observe` is not overrode' do
    expect { subject.observe }.to raise_error
  end

  describe 'attribute' do

    it 'can be given by constructor parameters' do
      klass = Class.new(Observed::Observer) do
                attribute :timeout_in_milliseconds
                attribute :number_of_trials
              end

      subject = klass.new(
          timeout_in_milliseconds: 5000,
          number_of_trials: 5000,
          tag: 'tag'
      )

      expect(subject.timeout_in_milliseconds).to eq(5000)
      expect(subject.number_of_trials).to eq(5000)
      expect(subject.tag).to eq('tag')
    end

    it 'can have a default value' do
      klass = Class.new(Observed::Observer) do
                attribute :timeout_in_milliseconds
                attribute :number_of_trials
                default :timeout_in_milliseconds => 5000
                default :number_of_trials => 5000
                default :tag => 'tag'
              end

      subject = klass.new

      expect(subject.timeout_in_milliseconds).to eq(5000)
      expect(subject.number_of_trials).to eq(5000)
      expect(subject.tag).to eq('tag')
    end

    context 'without a default value or a given value' do
      it 'raises errors when accessed' do
        klass = Class.new(Observed::Observer) do
                  attribute :timeout_in_milliseconds
                  attribute :number_of_trials
                end

        subject = klass.new

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

    context 'with one named plugin' do
      let(:klass) {
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

          plugin_name 'observer_spec_foo'
        end
      }
      before {
        klass
      }
      it 'returns the plugin' do
        expect(Observed::Observer.find_plugin_named('observer_spec_foo')).to eq(klass)
      end
    end

    context 'with two named plugins' do
      let(:bar) {
        Class.new(Observed::Observer) do
          plugin_name 'observer_spec_bar'
        end
      }
      let(:baz) {
        Class.new(Observed::Observer) do
          plugin_name 'observer_spec_baz'
        end
      }
      before {
        bar
        baz
      }
      it 'returns each plugin' do
        expect(Observed::Observer.find_plugin_named('observer_spec_bar')).to eq(bar)
        expect(Observed::Observer.find_plugin_named('observer_spec_baz')).to eq(baz)
      end
    end

  end

end
