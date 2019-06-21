{ Botkit } = require 'botkit'
{ FacebookAdapter, FacebookEventTypeMiddleware } = require 'botbuilder-adapter-facebook'

{replace} = require 'lodash/fp'



bus = require '../event_bus'
botkit = require './botkit'
{
  fb_messages_text_contains
  apply_fn_to_fb_messages
  msec_delay
  format
  df_text_message_format
} = require './df_to_messenger_formatter'
{regex, Js} = require '../helpers'


is_get_started_postback = (fb_message) ->
  fb_message.type is 'facebook_postback' and fb_message.text.match 'GET_STARTED'


is_tell_me_more_postback = (fb_message) ->
  fb_message.type is 'facebook_postback' and fb_message.text.match regex.tell_me_more


is_follow_up_postback = (fb_message) ->
  fb_message.type is 'facebook_postback' and fb_message.text?.match regex.follow_up


is_follow_up_message = (fb_message) ->
  fb_message.type is 'message_received' and fb_message.quick_reply?.payload.match regex.follow_up


swap_in_user_name = ({fb_message, fb_messages}) ->
  new Promise (resolve, reject) ->
    if fb_messages_text_contains fb_messages, '#generic.fb_first_name'
      bus.emit 'Looking up username in storage'
      botkit.storage.users.get fb_message.user, (err, user_data) ->
        if user_data.first_name?
          resolve apply_fn_to_fb_messages fb_messages, replace '#generic.fb_first_name', user_data.first_name
        else
          resolve fb_messages
    else
      resolve fb_messages


send_queue = ({fb_messages, fb_message:original_fb_message, bot}) ->
  bot.reply original_fb_message, sender_action: 'typing_on'
  cumulative_wait = 1000
  processed_fb_messages = await swap_in_user_name {fb_messages, fb_message:original_fb_message}
  processed_fb_messages.forEach (message, index) ->
    do (bot, original_fb_message, message, cumulative_wait) ->
      setTimeout () ->
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
          bot.reply original_fb_message, sender_action: 'typing_on'
          bus.emit "Sending typing indicator to Messenger, delayed by #{typing_delay}"
        , typing_delay

    cumulative_wait += msec_delay message


process_df_response_into_fb_messages = ({fb_message, df_result, bot}) ->
  fb_messages = format df_result.fulfillmentMessages
  send_queue {fb_messages, fb_message, bot}


tell_me_more = ({fb_message, bot}) ->
  tell_me_more_content = fb_message.text.match(/^tell_me_more: ?([\s\S]*)/i)?[1]
  fb_messages = format df_text_message_format tell_me_more_content
  send_queue {fb_messages, fb_message, bot}


check_user_type = ({fb_message, bot}) ->
  botkit.storage.users.get fb_message.user, (err, user_data) ->
    if user_data.user_type?
      bus.emit 'user returns with type set', {
        fb_message
        bot
        user_type: user_data.user_type
        df_session: fb_message.sender.id
      }
    else
      bus.emit 'user with unknown type starts', {fb_message, bot}


store_user_type = ({user_type, fb_message}) ->
  bus.emit 'Saving user type to db'
  botkit.storage.users.get fb_message.user, (err, user_data) ->
    user_data.user_type = user_type
    botkit.storage.users.save user_data


check_session = ({fb_message, df_response, bot, df_session}) ->
  botkit.storage.users.get fb_message.user, (err, user_data) ->
    if user_data.last_session_id isnt df_session
      user_data.last_session_id = df_session
      botkit.storage.users.save user_data
      bus.emit 'user session changed', {
        fb_message
        bot
        user_type: user_data.user_type
        fb_first_name: user_data.first_name
        df_session
        df_response
      }


botkit.hears ['(.*)'], 'message_received', (bot, fb_message) ->
  event = switch
    when is_get_started_postback fb_message then 'postback: get started'
    when is_tell_me_more_postback fb_message then 'postback: tell me more'
    when is_follow_up_postback fb_message then 'postback: follow up'
    when is_follow_up_message fb_message then 'quick reply: follow up'
    else 'message from user'
  bus.emit event, {fb_message, bot}


module.exports = {
  process_df_response_into_fb_messages
  tell_me_more
  check_user_type
  check_session
  store_user_type
}
