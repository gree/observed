require 'spec_helper'
require 'observed'
require 'observed/builtin_plugins'

describe Observed do
  include FakeFS::SpecHelpers

  describe '#load!`' do

    context 'with a relative file path under the current working directory' do

      subject do
        mod = Module.new do
          extend Observed
        end
        mod.load! './observed.rb'
        mod.config
      end

      context 'with invalid file path' do
        it 'should raise an error while loading' do
          expect { subject }.to raise_error(%r|No such file or directory.+observed\.rb|)
        end
      end

      context 'with a valid relative file path' do
        before do
          File.open('./observed.rb', 'w') do |file|
            file.write(
                <<-EOS
                report /foo/, via: 'stdout'
                EOS
            )
          end
        end

        it 'should load observed.rb' do
          expect { subject }.to_not raise_error
        end
      end
    end

    context 'with an absolute file path' do

      subject {
        mod = Module.new do
          extend Observed
        end
        mod.load! '/tmp/foo/observed_conf.rb'
        mod.config
      }

      context 'when the file does not exist' do

        it 'fails to load it' do
          expect { subject }.to raise_error(%r|No such file or directory - /tmp/foo/observed_conf.rb|)
        end
      end

      context 'when the file exists' do

        before {
          FileUtils.mkdir_p('/tmp/foo')
          File.open('/tmp/foo/observed_conf.rb', 'w') do |f|
            f.write(
                <<-EOS
                report /foo/, via: 'stdout'
                EOS
            )
          end
        }

        it 'succeeds to load it' do
          expect { subject }.to_not raise_error
        end
      end
    end
  end

  describe 'when included' do
    subject {
      ctx = ::Object.new
      ctx.extend Observed
      ctx
    }
    let(:t) {
      Time.now
    }
    let(:common) {
      'common'
    }
    let(:out) {
      out = mock('out1')
      out
    }
    it 'can be used to define components and trigger them immediately' do
      out.expects(:write).with(tag:'t', foo:1, foo2:1, bar:2, bar2:2, baz:3, baz2:3, r3:'common', time: t)
        .at_least_once
      report_to_out = subject.report do |data, options|
        out.write data.merge(baz2:data[:baz]).merge(r3: common).merge(options)
      end
      observe_then_translate_then_report = (
        subject.observe 'foo' do |data|
          data.merge(foo2:data[:foo],bar:2)
        end
      ).then(
        subject.translate do |data, options|
          data.merge(bar2:data[:bar],baz:3)
        end
      ).then(
        report_to_out
      )

      observe_then_translate_then_report.now({foo:1}, {tag: 't', time: t})

    end
    context 'with plugins' do
      before {
        class TestObserver < Observed::Observer
          plugin_name 'test1'
          def observe(data, options)
            data.merge({foo2:data[:foo],bar:2})
          end
        end
        class TestTranslator < Observed::Translator
          plugin_name 'test1'
          def translate(data, options)
            data.merge({bar2:data[:bar],baz:3})
          end
        end
        class TestReporter < Observed::Reporter
          plugin_name 'test1'
          attribute :common
          include Observed::Reporter::RegexpMatching
          def report(data, options)
            out = options[:out]
            options = options.dup
            options.delete :out
            out.write data.merge({baz2:data[:baz],r3:common}.merge(options))
          end
        end

        out.expects(:write).with(tag:'t', foo:1, foo2:1, bar:2, bar2:2, baz:3, baz2:3, r3:'common', time: t)
          .at_least_once
      }
      it 'can be used to define components from plugins and trigger them immediately' do
        observe_then_translate_then_report = (subject.observe via: 'test1')
          .then(subject.translate via: 'test1')
          .then(subject.report via: 'test1', with: {common: common})

        observe_then_translate_then_report.now({foo:1}, {tag: 't', time: t, out: out})
      end
      it 'can be used to send and receive tagged events' do
        require 'observed/job'
        require 'observed/jobbed_event_bus'
        executor = Observed::BlockingJobExecutor.new
        job_factory = Observed::JobFactory.new(executor: executor)
        bus = Observed::JobbedEventBus.new(job_factory: job_factory)

        observe_then_send = (subject.observe via: 'test1')
          .then(bus.pipe_to_emit 'foo1')

        bus.receive(/foo1/)
          .then(subject.translate via: 'test1')
          .then(subject.report via: 'test1', with: {common: common})

        observe_then_send.now({foo:1}, {tag: 't', time: t, out: out})
      end
      it 'can be used to send and receive tagged events with the default event bus' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        observe_then_send = (subject.observe via: 'test1')
          .then(subject.emit 'foo2')

        subject.receive(/foo2/)
          .then(subject.translate via: 'test1')
          .then(subject.report via: 'test1', with: {common: common})

        observe_then_send.now({foo:1}, {tag: 't', time: t, out: out})
      end
      it 'provides the way to send the tagged events with a bit shorter code' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        observe_then_send = (subject.observe 'foo3', via: 'test1')

        subject.receive(/foo3/)
          .then(subject.translate via: 'test1')
          .then(subject.report via: 'test1', with: {out: out, common: common})

        observe_then_send.now({foo:1}, {tag: 't', time: t, out: out})
      end
      it 'provides the way to receive the tagged events with a bit shorter code' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        observe_then_send = (subject.observe via: 'test1')
          .then(subject.translate via: 'test1')
          .then(subject.emit('bar'))

        subject.report /bar/, via: 'test1', with: {out: out, common: common}

        observe_then_send.now({foo:1}, {tag: 't', time: t, out: out})
      end
      it 'provides the way to group up observations' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        subject.group :a, [
          (subject.observe via: 'test1')
            .then(subject.translate via: 'test1')
            .then(subject.emit('baz'))
        ]

        subject.report /baz/, via: 'test1', with: {out: out, common: common}

        subject.group(:a).each do |observe_something|
          observe_something.now({foo:1}, {tag: 't', time: t, out: out})
        end
      end
      it 'provides the way to group up observations by their tags' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        subject.observe 'hoge', via: 'test1'

        subject.receive(/hoge/)
          .then(subject.translate via: 'test1')
          .then(subject.report via: 'test1', with: {out: out, common: common})

        subject.group('hoge').each do |observe_something|
          observe_something.now({foo:1}, {tag: 't', time: t, out: out})
        end
      end
      it 'provides the way to run a group of observations in single method call' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        subject.observe 'hoge', via: 'test1'

        subject.receive(/hoge/)
        .then(subject.translate via: 'test1')
        .then(subject.report via: 'test1', with: {out: out, common: common})

        subject.run_group('hoge').now({foo:1}, {tag: 't', time: t, out: out})
      end
      it 'provides a short-cut for running a group of observations' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        subject.observe 'fuga', via: 'test1'

        subject.receive(/fuga/)
          .then(subject.translate via: 'test1')
          .then(subject.report via: 'test1', with: {out: out, common: common})

        subject.run('fuga', {foo:1}, {tag: 't', time: t, out: out})
      end
      it 'provides the default values for the option `tag` and `time`' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        subject.observe 't', via: 'test1'

        subject.receive(/t/)
          .then(subject.translate via: 'test1')
          .then(subject.report via: 'test1', with: {out: out, common: common})

        ::Time.stubs(now: t)

        subject.run('t', {foo:1}, {out: out})
      end
      it 'allows to use emit/receive for subscribing to internal events' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        subject.receive('foo123')
          .then(
            (subject.observe via: 'test1')
              .then(subject.translate via: 'test1')
              .then(subject.report via: 'test1', with: {out: out, common: common})
          )

        ::Time.stubs(now: t)

        subject.emit('foo123').now({foo:1}, {out: out, tag: 't', time: Time.now})
      end
      it 'allows to use emit/receive for subscribing to internal events to trigger receive/translate/report' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        subject.receive('kuroko1')
          .then(subject.observe via: 'test1')
          .then(subject.translate via: 'test1')
          .then(subject.emit 'kuroko2')

        subject.receive('kuroko2')
          .then(subject.report via: 'test1', with: {out: out, common: common})

        ::Time.stubs(now: t)

        subject.emit('kuroko1').now({foo:1}, {out: out, tag: 't', time: Time.now})
      end
      it 'allows to just report something' do
        require 'observed/job'

        subject.configure executor: Observed::BlockingJobExecutor.new

        subject.receive('kuroko3')
          .then(subject.report via: 'test1', with: {out: out, common: common})

        ::Time.stubs(now: t)

        subject.emit('kuroko3').now({foo:1, foo2:1, bar:2, bar2:2, baz: 3, baz2:3, r3: common}, {out: out, tag: 't', time: Time.now})
      end
    end

  end
end
