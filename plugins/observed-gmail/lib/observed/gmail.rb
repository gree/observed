# coding: utf-8

require 'observed/gmail/receiver'
require 'observed/gmail/sender'
require 'observed'
require 'gmail'

module Observed
  module Plugins
    class GmailObserver < Observed::Observer
      plugin_name 'gmail'
    
      attribute :userid
      attribute :passwd
      attribute :action, default: :fetch
      attribute :option, default: :all
    
      DEFAULT_COUNT = 3
    
      def observe
        gmail = Gmail.new(userid, passwd)
    
        plugin = GmailReceiver.new(gmail)
    
        result = nil
        case action
        when :fetch, :get, :receive
          result = plugin.fetch(option)
        else
          fail "The action of '#{action}' does not supported."
        end
    
        if result != nil
          system.report(self.tag, Time.now, result)
        end
    
        gmail.logout
      end
    end
    
    class GmailReporter < Observed::Reporter
      plugin_name 'gmail'
    
      include Observed::Reporter::RegexpMatching
    
      attribute :userid
      attribute :passwd
      attribute :header, default: {}
      attribute :action, default: :send
    
      attribute :body, default: -> tag, time, data { "#{Time.at(time)} #{tag} #{data}" }
    
      def report(tag, time, context)
        gmail = Gmail.new(userid, passwd)
    
        plugin = GmailSender.new(gmail, context)
    
        case action
        when :send
          plugin.send(header, body)
        else
          fail "The action of '#{action}' does not supported."
        end
    
        gmail.logout
      end
    end
  end
end
