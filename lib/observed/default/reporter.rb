require 'observed/reporter'
require 'observed/reporter/regexp_matching'
require 'observed/reporter/writer_writing'

module Observed
  module Default
    class Reporter < Observed::Reporter
      include Observed::Reporter::RegexpMatching
      include Observed::Reporter::WriterReporting

      attribute :writer

    end
  end
end
