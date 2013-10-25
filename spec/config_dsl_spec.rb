require 'spec_helper'
require 'observed/config_dsl'

describe Observed::ConfigDSL do
  subject {
    Observed::ConfigDSL.new(:plugins_directory => '.')
  }
  it 'creates a config' do
    subject.instance_eval do
      observe 'foo', plugin: 'foo', name: 'name'
    end

    expect(subject.config).to eq({'foo' => {plugin: 'foo', name: 'name'}})
  end
end
