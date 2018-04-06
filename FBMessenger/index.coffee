EventEmitter = require('events').EventEmitter
inherits = require('util').inherits

FB = () ->
FB.prototype =
  handle: (df_response) ->
    console.log "* Dealing with DialogFlow's response (#{df_response}) – splitting it up and queuing it to send, formatting buttons etc"
  tell_me_more: (fb_message) ->
    console.log "* Formatting tell me more portion of postback (#{fb_message}) and sending it back to Messenger…"

inherits FB, EventEmitter

module.exports = FB
