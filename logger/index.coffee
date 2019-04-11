mongoose = require 'mongoose'

db = require './db'
bus = require '../event_bus'


log_event = (obj) ->
  event = new db.Event {
    obj...
    # timestamp: Date.now()
  }
  event.save()
    .catch (e) -> bus.emit 'error', e


module.exports =
  from_fb: ({fb_message}) ->
    log_event
      # user_id: fb_message.user
      event_type: 'from_fb'
      user_said: fb_message.text


  from_df: ({fb_message, df_result, df_session}) ->
    log_event
      event_type: 'from_df'
      # user_id: fb_message.user
      df_session: df_session
      df_messages: df_result.fulfillmentMessages


  to_fb: ({fb_message, message}) ->
    log_event
      type: 'to_fb'
      # user_id: fb_message.user
      bot_said: message
