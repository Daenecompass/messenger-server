mongoose = require 'mongoose'

{ Event, User } = require '../db'
{ emit_error } = require '../helpers'


log_event = (obj) ->
  new Event { obj... }
    .save()
    .catch emit_error


module.exports =
  user_starts: ({ fb_message }) ->
    User.findOneAndUpdate {
        _id: fb_message.user
      }, {
        $push: starts: platform: 'messenger'
        last_platform: 'messenger'
      }, {
        upsert: true
        setDefaultsOnInsert: true
      }
      .catch emit_error


  from_fb: ({fb_message}) ->
    log_event
      user: fb_message.user
      event_type: 'from_fb'
      user_said: fb_message.text
      user_quick_reply: fb_message.quick_reply?.payload


  from_df: ({fb_message, df_result, df_session}) ->
    log_event
      event_type: 'from_df'
      user: fb_message.user
      df_session: df_session
      df_messages: df_result.fulfillmentMessages
      df_intent: df_result.intent.displayName
      df_confidence: df_result.intentDetectionConfidence


  to_fb: ({fb_message, message}) ->
    log_event
      event_type: 'to_fb'
      user: fb_message.user
      bot_said: message


  feedback: ({user_id, feedback}) ->
    User.findOneAndUpdate user_id, {$push: feedback: feedback: feedback }, upsert: true
      .catch emit_error
