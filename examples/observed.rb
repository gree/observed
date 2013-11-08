class Test < Observed::Observer
  plugin_name 'test'
  def observe
    system.report(tag, {foo:1})
  end
end

observe 'foo', via: 'test'

report /foo/, via: 'stdout'
