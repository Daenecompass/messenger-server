{users_collection, events_collection} = require './db'
bus = require '../event_bus'


log_event = (obj) ->
  try
    events = await events_collection()
    events.insertOne {obj..., timestamp: Date.now()}
  catch e
    bus.emit 'error:', e
    null


module.exports =
  from_fb: ({fb_message}) ->
    log_event
      type: 'from_fb'
      user_id: fb_message.user
      user_said: fb_message.text


  from_df: ({fb_message, df_result, df_session}) ->
    log_event
      type: 'from_df'
      user_id: fb_message.user
      df_session: df_session
      df_messages: df_result.fulfillmentMessages


  to_fb: ({fb_message, message}) ->
    log_event
      type: 'to_fb'
      user_id: fb_message.user
      bot_said: message
