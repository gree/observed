require "observed/gmail/base"

module Observed
  module Plugins
    class GmailReceiver < GmailBase
      DEFAULT_COUNT = 3

      def initialize obj
        super obj
      end
    
      def fetch option
        max_count = option[:count] != nil ? option[:count] : DEFAULT_COUNT
        cur_count = 0
        results = []
    
        @gmail.inbox.emails(option).reverse.each do |mail|
          response = { header: {}, body: "" }

          response[:header][:subject] = mail.subject
          response[:header][:date] = mail.date
          response[:header][:from] = mail.from
          response[:header][:to] = mail.to
    
          if !mail.text_part && !mail.html_part
            response[:body] = mail.body.decoded.encode("UTF-8", mail.charset)
          elsif mail.text_part
            response[:body] = mail.text_part.decoded
          elsif mail.html_part
            response[:body] = mail.html_part.decoded
          end 

          results << response

          cur_count += 1

          break if cur_count >= max_count
        end

        results
      end
    end
  end
end
