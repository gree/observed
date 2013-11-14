require 'spec_helper'

require 'observed/observer'
require 'observed/observer_helpers/timer'
require 'observed/configurable'

describe describe Observed::ObserverHelpers::Timer do

  before {
    subject.configure system: sys, logger: logger
  }

  let(:sys) {
    sys = stub('system')
    sys.stubs(:now).returns(before).then.returns(after)
    sys
  }

  let(:before) { Time.now }

  let(:after) { Time.now + 1 }

  let(:logger) {
    mock('logger')
  }

  context 'when included to the new Observer implementation class' do
    subject {
      klass = Class.new(Observed::Observer) do
        include Observed::ObserverHelpers::Timer
        include Observed::Configurable
        include Observed::Logging

        def observe(data)
          [tag, data]
        end
      end
      klass.new
    }
    it 'returns the result instead of reporting it via the system' do
      data = ['test.success', {status: :success, result: 'the result', elapsed_time: after - before }]

      expect(
          subject.time_and_report(tag: 'test', timeout_in_seconds: 1.0) do
            'the result'
          end
      ).to eq(data)
    end
  end

  context 'when its logging enabled' do

    subject {
      klass = Class.new(Observed::Observer) do
        include Observed::ObserverHelpers::Timer
        include Observed::Configurable
        include Observed::Logging
      end
      klass.new
    }

    describe 'its `time` method' do
      context 'when missing :timeout_in_seconds parameter' do
        it 'fails' do

          expect {
            subject.time({}) do
              fail 'This block should not be called'
            end
          }.to raise_error(/The key `:timeout_in_seconds` must be exist in the options/)

        end
      end

      context 'with correct parameters' do
        context 'given the block which does not time out' do
          it 'returns the result containing its status, value, elapsed time' do

            expect(
              subject.time({timeout_in_seconds: 1.0}) do
                'test_value'
              end
            ).to eq(status: :success, result: 'test_value', elapsed_time: after - before)

          end

          context 'given the block which does time out' do
            it 'returns the result containing its status, flag, message while logging the error' do

              logger.expects(:debug).once
              expect(
                subject.time(timeout_in_seconds: 1.0) do
                  raise Timeout::Error
                end
              ).to eq(status: :error, timed_out: true, error: {message: 'Timed out.'})

            end
          end

          context 'given the block which fails' do
            it 'returns the result containing its status, message while logging the error' do

              logger.expects(:error).once
              expect(
                subject.time(timeout_in_seconds: 1.0) do
                  raise RuntimeError, 'The error message'
                end
              ).to eq(status: :error, error: {message: 'The error message'})

            end
          end
        end
      end

    end
  end

  context 'when its logging disabled' do

    subject {
      klass = Class.new(Observed::Observer) do
        include Observed::ObserverHelpers::Timer
        include Observed::Configurable
      end
      klass.new
    }

    describe 'its `time` method' do
      context 'with correct parameters' do
        context 'given the block which does time out' do
          it 'returns the result containing its status, flag, message while not logging the error' do

            logger.expects(:debug).never
            expect(
              subject.time(timeout_in_seconds: 1.0) do
                raise Timeout::Error
              end
            ).to eq(status: :error, error: {message: 'Timed out.'}, timed_out: true)
          end
        end

        context 'given the block which fails' do
          it 'returns the result containing its status, message while not logging the error' do

            logger.expects(:error).never
            expect(
              subject.time(timeout_in_seconds: 1.0) do
                raise StandardError, 'The error message'
              end
            ).to eq(status: :error, error: {message: 'The error message'})

          end
        end
      end
    end

    describe 'its `time_and_report` method' do
      context 'when :tag parameter is not given' do
        it 'fails' do

          expect {
            subject.time_and_report(timeout_in_seconds: 1.0) do
              'the result'
            end
          }.to raise_error

        end
      end

      context 'when :tag parameter is given' do
        it 'reports the result of `time`' do

          data = ['test.success', {status: :success, result: 'the result', elapsed_time: after - before }]

          sys.expects(:report).with(*data).once

          expect(
            subject.time_and_report(tag: 'test', timeout_in_seconds: 1.0) do
              'the result'
            end
          ).to eq(data)

        end
      end
    end
  end
end
