bus = require '../event_bus'
fb_messenger_botkit = require './botkit'
helpers = require '../helpers'

is_get_started_postback = (fb_message) ->
  fb_message.type is 'facebook_postback' and fb_message.text.match 'GET_STARTED'

fb_messenger_botkit.hears ['(.*)'], 'message_received', (bot, fb_message) ->
  if is_get_started_postback fb_message
    bus.emit 'postback: get started', fb_message, bot
  else
    bus.emit 'message from user', fb_message, bot

module.exports =
  handle_very_plain_message: (fb_message, df_response, bot) ->
    if df_response.result.fulfillment.messages?[0].speech?
      bot.reply fb_message, df_response.result.fulfillment.messages[0].speech
    else
      # need to queue up and deal with complex messages (buttons etc)
      console.log "Looks like a more complex df response than I can currently work with:"
      console.log df_response.result.fulfillment.messages

  check_user_type: (fb_message, bot) ->
    fb_messenger_botkit.storage.users.get fb_message.user, (err, user_data) ->
      if user_data.user_type?
        bus.emit 'user returns with type set', fb_message, bot, user_data.user_type
      else
        bus.emit 'brand new user starts', fb_message, bot

  check_session: (fb_message, df_response, bot, df_session) ->
    fb_messenger_botkit.storage.users.get fb_message.user, (err, user_data) ->
      if user_data.last_session_id isnt df_session  # new session started
        user_data.last_session_id = df_session
        fb_messenger_botkit.storage.users.save user_data
        if user_data.user_type?
          bus.emit 'user session changed', fb_message, bot, user_data.user_type
