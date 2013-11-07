require 'spec_helper'
require 'observed/config_dsl'

describe Observed::ConfigDSL do
  subject {
    Observed::ConfigDSL.new
  }
  it 'creates a config' do
    subject.instance_eval do
      observe 'foo', plugin: 'foo', name: 'name'
      match 'foo', plugin: 'stdout'
    end

    expect(subject.config).to eq({ observers: {'foo' => {plugin: 'foo', name: 'name'}}, reporters: {'foo' => {plugin: 'stdout'}}})
  end
end
