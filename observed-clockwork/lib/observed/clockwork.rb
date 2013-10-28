require 'clockwork'
require 'observed'
require "observed/clockwork/version"
require "observed/application"

module Observed
  module Clockwork
    extend self

    def load_and_register_handler!(args)
      Handler.create(args).register!
    end

    alias observed load_and_register_handler!

    class Handler

      def initialize(app)
        @app = app
      end

      def call(job)
        @app.run(job)
      end

      def register!
        ::Clockwork.handler do |job|
          self.call job
        end
      end

      class << self

        def create(args)
          args[:plugins_directory] ||= '.'

          Observed.init!
          Observed.configure args
          Observed.load!(args[:config_file])

          config = Observed.config
          app = Observed::Application::Oneshot.create(:config => config)

          self.new(app)
        end

        alias create_from_observed create
      end
    end

  end
end
