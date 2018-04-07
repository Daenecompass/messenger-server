EventEmitter = require('events').EventEmitter

df = require '../DialogFlow'
fb_messenger_botkit = require('./botkit')
postbacks = require './postbacks'
helpers = require '../helpers'

fb =
  handle: (fb_message, df_response, bot) ->
    bot.reply fb_message, 'got something from DF'
    # console.log "* Dealing with DialogFlow's response (#{df_response}) – splitting it up and queuing it to send, formatting buttons etc"
  tell_me_more: (fb_message) ->
    df.handle helpers.remove_tell_me_more_in_fb_message fb_message
    # console.log "* Formatting tell me more portion of postback (#{fb_message}) and sending it back to Messenger…"
Object.assign fb, EventEmitter.prototype

fb.on 'regular user message', df.handle
fb.on 'tell me more postback', fb.tell_me_more
fb.on 'follow up postback', df.follow_up
fb.on 'get started postback', df.get_started


fb_messenger_botkit.controller.hears ['(.*)'], 'message_received', (bot, fb_message) ->
  df.handle fb_message, bot
  # route_postbacks fb_message
  # route_locally_handled fb_message
  # route_messages_for_diagloflow fb_message

module.exports = fb
