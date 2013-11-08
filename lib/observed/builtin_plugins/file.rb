require 'observed/hash/fetcher'
require 'observed/reporter'
require 'observed/reporter/regexp_matching'

module Observed
  module BuiltinPlugins
    class File < Observed::Reporter

      include Observed::Reporter::RegexpMatching

      UNDEFINED = Object.new

      attribute :format, default: -> tag, time, data { "#{Time.at(time)} #{tag} #{data}" }
      attribute :path
      attribute :mode, default: :append

      # @param [String] tag
      # @param [Time] time
      # @param [Hash] data
      def report(tag, time, data)
        num_params = format.parameters.size
        formatted_data = case num_params
                         when 3
                           format.call(tag, time, data)
                         when 4
                           format.call(tag, time, data, Observed::Hash::Fetcher.new(data))
                         else
                           fail "Number of parameters for the function for the key :format must be 3 or 4, but was #{num_params}(#{format.parameters}"
                         end
        mode = case self.mode
               when :append, 'a'
                 'a'
               when :overwrite, 'w'
                 'w'
               else
                 fail "Unsupported value for the parameter `:mode`: Supported values are :append, :overwrite, " +
                     "'a', 'w'. The specified value is #{self.mode.inspect}"
               end
        ::File.open(path, mode) do |f|
          f.puts formatted_data
        end
      end

      def self.plugin_name
        'file'
      end
    end
  end
end
