require 'observed/http'

observe 'google.health', via: 'http', with: {
    method: 'get',
    url: 'http://www.google.co.jp/'
}

report /google.health/, via: 'stdout', with: {
    format: -> tag, time, data {
      case data[:status]
      when :success
        'Google is healthy! (^o^)'
      else
        'Google is unhealthy! (;_;)'
      end
    }
}
