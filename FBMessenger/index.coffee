'use strict'

{ replace } = require 'lodash/fp'

bus = require '../event_bus'
{ botkit } = require './botkit'
{ get_facebook_profile, send_typing } = require './facebook_api'
{
  fb_messages_text_contains
  apply_fn_to_fb_messages
  msec_delay
  format
  df_text_message_format
} = require './df_to_messenger_formatter'
{ regex, emit_error } = require '../helpers'
{ User } = require '../db'


swap_in_user_name = ({ fb_message, fb_messages }) ->
  fb_user_id = fb_message.user
  new Promise (resolve, reject) ->
    if fb_messages_text_contains fb_messages, '#generic.fb_first_name'
      bus.emit 'Looking up username in storage'
      user = await User.findOne _id: fb_user_id
      if user?.fb_user_profile?.first_name?
        { first_name } = user.fb_user_profile
      else
        fb_user = await get_facebook_profile fb_user_id
        { first_name } = fb_user
        query = _id: fb_user_id
        update = fb_user_profile: fb_user
        options =
          new: true
          upsert: true
          setDefaultsOnInsert: true
        User.findOneAndUpdate query, update, options, (err, doc) ->
          if err
            emit_error err
          else if not doc
            emit_error 'User not found in db'
          else
            bus.emit 'Saved FB profile to db'

      resolve apply_fn_to_fb_messages fb_messages, replace '#generic.fb_first_name', first_name

    else
      resolve fb_messages


send_queue = ({ fb_messages, fb_message:original_fb_message, bot }) ->
  await bot.changeContext original_fb_message.reference
  send_typing original_fb_message
 
  cumulative_wait = 1000
  processed_fb_messages = await swap_in_user_name {fb_messages, fb_message:original_fb_message}
  processed_fb_messages.forEach (message, index) ->
    do (bot, original_fb_message, message, cumulative_wait) ->
      setTimeout () ->
        await bot.changeContext original_fb_message.reference
        bot.reply original_fb_message, message
        bus.emit "Sending message #{index} to Messenger, delayed by #{cumulative_wait}"
        bus.emit 'message to user', {
          fb_message: original_fb_message
          message
        }
      , cumulative_wait

      if index < processed_fb_messages.length - 1
        next_message_delay = msec_delay message
        typing_delay = cumulative_wait + (next_message_delay * 0.75)
        setTimeout () ->
          await bot.changeContext original_fb_message.reference
          send_typing original_fb_message
          bus.emit "Sending typing indicator to Messenger, delayed by #{typing_delay}"
        , typing_delay

    cumulative_wait += msec_delay message


process_df_response_into_fb_messages = ({ fb_message, df_result, bot }) ->
  fb_messages = format df_result.fulfillmentMessages
  send_queue { fb_messages, fb_message, bot }


tell_me_more = ({ fb_message, bot }) ->
  tell_me_more_content = fb_message.text.match(/^tell_me_more: ?([\s\S]*)/i)?[1]
  fb_messages = format df_text_message_format tell_me_more_content
  send_queue { fb_messages, fb_message, bot }


check_user_type = ({ fb_message, bot }) ->
  user = await User.findOne _id: fb_message.user
  if user?.user_type?
    bus.emit 'user returns with type set', {
      fb_message
      bot
      user_type: user.user_type
      df_session: fb_message.sender.id
    }
  else
    bus.emit 'user with unknown type starts', { fb_message, bot }


store_user_type = ({ user_type, fb_message }) ->
  query = _id: fb_message.user
  update = user_type: user_type
  options =
    new: true
    setDefaultsOnInsert: true
  User.findOneAndUpdate query, update, options, (err, doc) ->
    if err
      emit_error err
    else if not doc
      emit_error 'User not found in db'
    else
      bus.emit 'Saved user type to db'


check_session = ({ fb_message, df_response, bot, df_session }) ->
  user = await User.findOne _id: fb_message.user
  if user?.last_session_id is df_session
    return
  if user?.last_session_id isnt df_session
    bus.emit 'putting session in db'
    await User.findOneAndUpdate { _id: fb_message.user }, { last_session_id: df_session }, { upsert: true, new: true }
    bus.emit 'user session changed', {
      fb_message
      bot
      user_type: user?.user_type
      fb_first_name: user?.fb_user_profile?.first_name
      df_session
      df_response
    }


botkit.on 'message', (bot, fb_message) ->
  event = switch
    when fb_message.quick_reply?.payload.match regex.follow_up then 'quick reply: follow up'
    else 'message from user'
  bus.emit event, { fb_message, bot }


botkit.on 'facebook_postback', (bot, fb_message) ->
  event = switch
    when fb_message.text.match 'GET_STARTED' then 'postback: get started'
    when fb_message.text.match regex.tell_me_more then 'postback: tell me more'
    when fb_message.text?.match regex.follow_up then 'postback: follow up'
    when fb_message.text?.match regex.card_button then 'postback: card button'
  if event
    bus.emit event, { fb_message, bot }
  else
    bus.emit "error: unknown kinda postback: #{fb_message.text}"


module.exports = {
  process_df_response_into_fb_messages
  tell_me_more
  check_user_type
  check_session
  store_user_type
}
