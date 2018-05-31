ngrok = require 'ngrok'

ngrok
  .connect
    authtoken: process.env.ngrok_authtoken
    subdomain: process.env.ngrok_subdomain
    addr: process.env.PORT or 3000
  .then (url) ->
    console.log "Your bot is available at #{url}/facebook/receive"
  .catch (err) ->
    console.error err
