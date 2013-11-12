require 'spec_helper'
require 'observed/configurable'

module ConfigurableSpec
  class Foo
    include Observed::Configurable

    attribute :foo, default: 123
    attribute :bar, default: 234
    attribute :baz

    default :bar => 345
  end

  module Preset
    include Observed::Configurable

    attribute :preset, default: 123
  end

  module PresetInherited
    include Observed::Configurable
    include Preset
  end

  class ClassWithPreset
    include Observed::Configurable
    include Preset

    attribute :foo, default: 234
  end

  class ClassWithPresetInherited
    include Observed::Configurable
    include PresetInherited

    attribute :foo, default: 234
  end
end

describe Observed::Configurable do

  context 'without parameters for the constructor' do
    subject {
      ConfigurableSpec::Foo.new
    }
    it 'uses default values for attributes' do
      expect(subject.foo).to eq(123)
    end
    it 'overrides default values on `attribute name, :default => default_value`' do
      expect(subject.bar).to eq(345)
    end
    it 'raises errors when attributes without values are read' do
      expect { subject.baz }.to raise_error
    end
  end

  context 'with parameters for the constructor' do
    subject {
      ConfigurableSpec::Foo.new({foo: 1, bar: 2, baz: 3})
    }
    it 'prefers values from constructor parameters over defaults' do
      expect(subject.foo).to eq(1)
      expect(subject.bar).to eq(2)
      expect(subject.baz).to eq(3)
    end
  end

  context 'configured through `configure(args)` method' do
    subject {
      foo = ConfigurableSpec::Foo.new
      foo.configure(args)
      foo
    }
    shared_examples_for 'values are set' do
      it 'prefers values from `configure(args)` over defaults' do
        expect(subject.foo).to eq(1)
        expect(subject.bar).to eq(2)
        expect(subject.baz).to eq(3)
      end
    end
    context 'when args has symbol keys' do
      let(:args) {
        {foo: 1, bar: 2, baz: 3}
      }
      it_behaves_like 'values are set'
    end
  end

  shared_examples_for 'a preset provider' do
    it 'provides a preset of attributes' do
      expect(subject.foo).to eq(234)
      expect(subject.preset).to eq(123)

      subject.configure foo: 1, preset: 2

      expect(subject.foo).to eq(1)
      expect(subject.preset).to eq(2)
    end
  end

  context 'when included in a module' do
    subject {
      ConfigurableSpec::ClassWithPreset.new
    }
    it_behaves_like 'a preset provider'
  end

  context 'when included via a intermediate module' do
    subject {
      ConfigurableSpec::ClassWithPresetInherited.new
    }
    it_behaves_like 'a preset provider'
  end

end
