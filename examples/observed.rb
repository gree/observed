class Test < Observed::Observer
  plugin_name 'test'
  def observe
    [tag, {foo:1}]
  end
end

observe 'foo', via: 'test'

report /foo/, via: 'stdout'
