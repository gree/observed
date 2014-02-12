# Observed::Gmail

## Installation
This plugin has Observer and Reporter. Each of them provide getter/setter of Gmail.

## Observer
The gmail-observer provide function to get emails on Gmail.

### Example
Here is a simple example to use observed-gmail. This example shows emails that were received within the 24 hours.

    # coding: utf-8
    
    require 'observed'
    require 'observed/gmail'
    
    include Observed
    
    hoge = observe( 'receiver.test', via: 'gmail' , :with => {
      userid: '<userid of gmail-account>',
      passwd: '<password of gmail-account>',
      option: {
        after: Time.now - (24*3600), 
        count: 2
      },
    }).then(
      (report /receiver.test/, via: 'stdout', with: {
        format: -> tag, time, data {
          ret = ""
    
          data.each do |mail|
            ret << "---- #{mail[:header][:subject]} ----\n"
            ret << "#{mail[:body][0..400]}\n"
          end
    
          ret
        }
      })
    )
    
    run 'receiver.test'

### Attribute
- `userid` : user-id of Gmail account (required)
- `passwd` : password of Gmail account (required)
- `action` : method of operation. Now, supports attributes following. (default `fetch`)
    - `fetch` : gets emails from Inbox on Gmail
- `option` : filter fetched emails. Supported filtering parameters are following. (optional) 
    - `count`
    - `after`
    - `before`
    - `on`
    - `from`
    - `to`
    - `subject`
    - `label`
    - `attachment`
    - `search`
    - `body`
    - `query`

### Output
This observer report to same Event-Bus, which is detected by 'tag' name. An output context is Hash data, and the construction of it is following.

- `header` : has header attributes of email following.
    - `subject`
    - `date`
    - `from`
    - `to`
- `body` : has email body


## Reporter
The gmail-reporeter send email using Gmail.

### Example
This example sends an email in conjunction with observed-http plugin.

    # coding: utf-8
    require 'observed'
    require 'observed/http'
    require 'observed/gmail'
    
    include Observed
    
    hoge = observe( 'reporter.test', via: 'http' , :with => {
      method: 'get',
      url: 'http://www.google.co.jp/'
    }).then(
      (report /reporter.test/, via: 'gmail', with: {
        userid: '<userid of gmail-account>',
        passwd: '<password of gmail-account>',
        header: {
          to: "destination@example.com",
          subject: -> x { "result: #{x[:result]}" },
        },
        body: -> x {
          "status: #{x[:status]}"
        },
      }),
    )
    
    run 'reporter.test'

### Attribute

- `userid` : user-id of Gmail account (required)
- `passwd` : password of Gmail account (required)
- `header` : specifies email header attributes of email following. 
    - `to`
    - `subject`
- `body` : specifies email body

You can specify a String, Fixnum, and lambda expression for each :header and :body attributes.
