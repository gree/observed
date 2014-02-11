require 'spec_helper'

require 'observed'
require 'observed/gmail'

describe Observed::Plugins::GmailSender do
	subject {
		Observed::Plugins::GmailSender.new( gmail, input_data )
	}

	let(:mail) {
		mail = Mail.new
		mail.stubs(:deliver!).returns(nil)

		mail
	}

	let(:gmail) {
		gmail = mock('gmail')
		gmail.stubs(:compose).returns(mail)

		gmail
	}

	let(:input_data) {
		"input something"
	}

	it "test with static parameter" do
		header = {
			to: "to.text@example.com",
			subject: "static subject: ",
		}

		context = "static context"

		expect{ subject.send(header, context) }.to_not raise_error
	end

	it "test with dynamic parameter" do
		header = {
			to: "to.text@example.com",
			subject: -> x { "dynamic subject: #{x}" },
		}

		context = lambda {|x| "dynamic context #{x}"}

		expect{ subject.send(header, context) }.to_not raise_error
	end
end
