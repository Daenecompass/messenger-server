ngrok = require 'ngrok'

bus = require '../event_bus'
{emit_error} = require '../helpers'


ngrok
  .connect
    authtoken: process.env.ngrok_authtoken
    subdomain: process.env.ngrok_subdomain
    addr: process.env.PORT or 3000
  .then (url) ->
    bus.emit "STARTUP: Webhook available at #{url}/facebook/receive"
  .catch emit_error
