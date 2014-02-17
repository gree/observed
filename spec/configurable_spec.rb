require 'spec_helper'
require 'observed/configurable'
require 'observed/pluggable'

module ConfigurableSpec
  class Foo
    include Observed::Configurable

    attribute :foo, default: 123
    attribute :bar, default: 234
    attribute :baz

    default :bar => 345
  end

  module ConfigurableModule
    include Observed::Configurable

    attribute :baz
  end

  module IntermediateModule
    include Observed::Configurable
    include ConfigurableModule

    attribute :bar, default: 234
  end

  class ConfigurableModuleIncluder
    include Observed::Configurable
    include ConfigurableModule

    attribute :bar, default: 234
    default :bar => 345
    attribute :foo, default: 123
  end

  class IntermediateModuleIncluder
    include Observed::Configurable
    include IntermediateModule

    default :bar => 345
    attribute :foo, default: 123
  end

  class SpecialCMI < ConfigurableModuleIncluder
    include Observed::Configurable
  end

  class SpecialIMI < IntermediateModuleIncluder
    include Observed::Configurable
  end

  class Plugin
    include Observed::Configurable
    include Observed::Pluggable
    include ConfigurableModule
    attribute :bar, default: 234
    default :bar => 345
  end

  class PluginImpl < Plugin
    include Observed::Configurable
    attribute :foo, default: 123
  end

  class Overriding
    include Observed::Configurable
    include IntermediateModule

    def foo
      @attributes[:foo] || 123
    end

    default :bar => 345
    attribute :foo, default: 1234
  end
end

describe Observed::Configurable do

  shared_examples_for 'a configurable object' do
    it 'uses default values for attributes' do
      expect(subject.new.foo).to eq(123)
    end

    it 'overrides default values on `attribute name, :default => default_value`' do
      expect(subject.new.bar).to eq(345)
    end

    it 'raises errors when attributes without values are read' do
      expect { subject.new.baz }.to raise_error
    end

    context 'when configured via the `configure` method' do
      it 'prefers arguments of the method over defaults' do
        instance = subject.new

        instance.configure foo: 1, bar: 2

        expect(instance.foo).to eq(1)
        expect(instance.bar).to eq(2)
      end
    end

    context 'when configured via constructor parameters' do
      context 'when the keys are symbols' do
        it 'prefers values from constructor parameters over defaults' do
          instance = subject.new({foo: 1, bar: 2, baz: 3})
          expect(instance.foo).to eq(1)
          expect(instance.bar).to eq(2)
          expect(instance.baz).to eq(3)
        end
      end
      context 'when the keys are strings' do
        it 'does not prefer constructor parameters' do
          instance = subject.new({'foo' => 1, 'bar' => 2, 'baz' => 3})
          expect(instance.foo).to eq(123)
          expect(instance.bar).to eq(345)
          expect { instance.baz }.to raise_error
        end
      end
    end
  end

  context 'when included in a class' do
    subject {
      ConfigurableSpec::Foo
    }
    it_behaves_like 'a configurable object'
  end

  context 'when included in a module' do
    subject {
      ConfigurableSpec::ConfigurableModuleIncluder
    }
    it_behaves_like 'a configurable object'
  end

  context 'when included via a intermediate module' do
    subject {
      ConfigurableSpec::IntermediateModuleIncluder
    }
    it_behaves_like 'a configurable object'
  end

  context 'when extended from a class which is a Plugin' do
    subject {
      ConfigurableSpec::PluginImpl
    }
    it_behaves_like 'a configurable object'
  end

  context 'when inherited from a class included the intermediate module' do
    subject {
      ConfigurableSpec::SpecialIMI
    }
    it_behaves_like 'a configurable object'
  end

  context 'when inherited from a class included the module includes it' do
    subject {
      ConfigurableSpec::SpecialCMI
    }
    it_behaves_like 'a configurable object'
  end

  context 'when there is a method named exactly same as the attribute' do
    subject {
      ConfigurableSpec::Overriding
    }
    it_behaves_like 'a configurable object'
  end

end
