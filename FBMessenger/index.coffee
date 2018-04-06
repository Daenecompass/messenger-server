EventEmitter = require('events').EventEmitter

fb_messenger_controller = require './controller'
postbacks = require './postbacks'
helpers = require '../helpers'

FB =
  handle: (df_response) ->
    console.log "* Dealing with DialogFlow's response (#{df_response}) – splitting it up and queuing it to send, formatting buttons etc"
  tell_me_more: (fb_message) ->
    console.log "* Formatting tell me more portion of postback (#{fb_message}) and sending it back to Messenger…"
Object.assign FB, EventEmitter.prototype

fb_messenger_controller.hears ['(.*)'], 'message_received', (bot, fb_message) ->
  route_postbacks fb_message, FB
  # route_locally_handled fb_message
  # route_messages_for_diagloflow fb_message

module.exports = FB
