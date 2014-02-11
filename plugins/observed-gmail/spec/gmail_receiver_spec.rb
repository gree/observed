require 'spec_helper'

require 'observed'
require 'observed/gmail'

describe Observed::Plugins::GmailReceiver do
	let(:receiver) {
		receiver = mock('receiver')

		receiver.stubs(:subject).returns('mail subject')
		receiver.stubs(:date).returns("2014-02-10")
		receiver.stubs(:from).returns("from.test@example.com")
		receiver.stubs(:to).returns("to.test@example.com")
		receiver.stubs(:text_part).returns(nil)
		receiver.stubs(:html_part).returns(nil)
		receiver.stubs(:body).returns(receiver)
		receiver.stubs(:charset).returns("UTF-8")

		receiver
	}

	let(:gmail) {
		gmail = mock('gmail')
		gmail.stubs(:inbox).returns(gmail)
		gmail.stubs(:emails).returns([receiver, receiver])

		gmail
	}

	subject {
		Observed::Plugins::GmailReceiver.new gmail
	} 

	after do
		expect{ subject.fetch({before: Time.now - (24*3600), count: 2}) }.to_not raise_error
	end

	it "receiving multipart emails" do
		receiver.stubs(:text_part).returns(receiver)
		receiver.stubs(:decoded).returns("multipart mail context")
	end

	it "receiving html emails" do
		receiver.stubs(:html_part).returns(receiver)
		receiver.stubs(:decoded).returns("html mail context")
	end

	it "receiving emails" do
		receiver.stubs(:decoded).returns("mail context")
	end
end
