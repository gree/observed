require 'spec_helper'
require 'observed/config_dsl'
require 'observed/observer'
require 'observed/reporter'
require 'observed/reporter/regexp_matching'
require 'observed/builder'

describe Observed::ConfigDSL do
  subject {
    Observed::ConfigDSL.new(builder: Observed::Builder.new(
        observer_plugins: observer_plugins,
        reporter_plugins: reporter_plugins,
        system: sys
    ))
  }
  let(:foo) {
    Class.new(Observed::Observer) do
      def foo

      end
      plugin_name 'foo'
    end
  }
  let(:stdout) {
    Class.new(Observed::Reporter) do
      include Observed::Reporter::RegexpMatching
      def bar

      end
      plugin_name 'stdout'
    end
  }
  let(:sys) {
    mock('sys')
  }
  let(:observer_plugins) {
    { 'foo' => foo }
  }
  let(:reporter_plugins) {
    { 'stdout' => stdout }
  }
  it 'creates a config' do
    subject.instance_eval do
      observe 'foo', via: 'foo', with: { name: 'name' }
      report 'foo', via: 'stdout'
    end

    #expect(subject.config).to eq({ observers: {'foo' => {plugin: 'foo', name: 'name'}}, reporters: {'foo' => {plugin: 'stdout'}}})
  end
end
