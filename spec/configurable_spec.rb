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
      foo.configure({foo: 1, bar: 2, baz: 3})
      foo
    }
    it 'prefers values from `configure(args)` over defaults' do
      expect(subject.foo).to eq(1)
      expect(subject.bar).to eq(2)
      expect(subject.baz).to eq(3)
    end
  end

end
