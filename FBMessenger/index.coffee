bus = require '../event_bus'
fb_messenger_botkit = require './botkit'
df_to_messenger = require './df_to_messenger_formatter'
helpers = require '../helpers'

is_get_started_postback = (fb_message) ->
  fb_message.type is 'facebook_postback' and fb_message.text.match 'GET_STARTED'

fb_messenger_botkit.hears ['(.*)'], 'message_received', (bot, fb_message) ->
  if is_get_started_postback fb_message
    bus.emit 'postback: get started', fb_message, bot
  else
    bus.emit 'message from user', fb_message, bot

send_queue = (fb_messages, original_fb_message, bot) ->
  cumulative_wait = 0
  fb_messages.forEach (message) ->
    do (bot, original_fb_message, message, cumulative_wait) ->
      setTimeout () ->
        bot.reply original_fb_message, message
      , cumulative_wait
    cumulative_wait += df_to_messenger.msec_delay message


module.exports =
  process_response_and_queue_messages: (fb_message, df_response, bot) ->
    df_messages = df_response.result.fulfillment.messages
    fb_messages = df_to_messenger.formatter df_messages
    send_queue fb_messages, fb_message, bot

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
