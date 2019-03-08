raven = require '../helpers/error-logging'

raven.context () ->
  {users_collection, events_collection} = require './db'


  log_event = (obj) ->
    events = await events_collection()
    events
      .insertOne {obj..., timestamp: Date.now()}
      .catch (e) -> console.error e


  module.exports =
    from_fb: ({fb_message}) ->
      log_event
        type: 'from_fb'
        user_id: fb_message.user
        user_said: fb_message.text


    from_df: ({fb_message, df_response, df_session}) ->
      log_event
        type: 'from_df'
        user_id: fb_message.user
        df_session: df_session
        df_messages: df_response.result?.fulfillment?.messages


    to_fb: ({fb_message, message}) ->
      log_event
        type: 'to_fb'
        user_id: fb_message.user
        bot_said: message
