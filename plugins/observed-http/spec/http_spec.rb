require 'spec_helper'

require 'observed/application/oneshot'

describe Observed::Application::Oneshot do
  subject {
    Observed::Application::Oneshot.create(
        config_file: 'spec/fixtures/observed.conf',
        plugins_directory: '.'
    )
  }
  it 'initializes' do
    expect(subject.run.size).not_to eq(0)
  end
end
