# mobile upload

A simple tool for uploading a product image nad information from SMS, Mobile Web, and Desktop.

Files not included:
- configure.rb

Live site: http://162.243.220.110/
- login/password: chris/a11ick

To use the demo:
- on mobile phone, or desktop navigate to http://162.243.220.110/
- on mobile, take a photo, enter information, and submit
- on desktop, drag and drop or select a photo, enter information and submit
- on SMS text 2402452779, and follow instructions (select photo, and add information: title/cost/quantity)

Goal:
- I initially wanted to build the backend of the system ontop of blockchain, and then build an SMS interface to that, but it proved quite difficult in the time frame. So I opted for a utility and server setup that would allow adding/viewing products. I suppose I should have added remove, but figured this was fine for a demo
- If I had a touch more time I'd have turned on the API so it would be easy to integrate this into a system. At this point, it does work, but it's not documented in a way that would allow for turn key integration. Also would allow incrementing and decrementing quantities, etc, the basic CRUD stuff.

Additional Notes:
- The server is Ubuntu 14.04, running NGINX, Passenger, Ruby 2.3.0, and Redis. Provisioned and setup from scratch.
- The webserver is written in Ruby and uses Sinatra, the Twilio API, and Amazon S3 for storing images.
- The mobile front end uses a solution I crafted myself for dealing with files from phone and still allowing for an AJAX upload.
