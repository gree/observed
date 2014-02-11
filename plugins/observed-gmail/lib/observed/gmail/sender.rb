require "observed/gmail/base"

module Observed
  module Plugins
    class GmailSender < GmailBase
      def initialize obj, input
        super obj

        @input = input
      end

      def send header, body
        email = @gmail.compose

        # set meta-configuration
        email.charset = 'utf-8'

        header.each do |param, value|
          email.send(param.to_sym, extract(value))
        end

        email.body extract(body)

        email.deliver!
      end

      private
      def extract param
        case param
        when String
          param
        when Fixnum
          param.to_s
        when Proc
          param.call(@input).to_s
        else
          fail "cannot parse #{param}"
        end
      end
    end
  end
end
