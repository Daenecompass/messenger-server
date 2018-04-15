bus = require '../event_bus'
botkit = require './botkit'
df_to_messenger = require './df_to_messenger_formatter'
helpers = require '../helpers'
{replace} = require 'lodash/fp'
{some} = require 'lodash'

is_get_started_postback = (fb_message) ->
  fb_message.type is 'facebook_postback' and fb_message.text.match 'GET_STARTED'

is_tell_me_more_postback = (fb_message) ->
  fb_message.type is 'facebook_postback' and fb_message.text.match helpers.tell_me_more_regex

is_follow_up_postback = (fb_message) ->
  fb_message.type is 'facebook_postback' and fb_message.text.match helpers.follow_up_regex

swap_in_user_name = ({fb_message, fb_messages}) ->
  new Promise (resolve, reject) ->
    if df_to_messenger.fb_messages_text_contains fb_messages, '#generic.fb_first_name'
      bus.emit 'Looking up username in storage'
      botkit.storage.users.get fb_message.user, (err, user_data) ->
        if user_data.first_name?
          resolve df_to_messenger.apply_fn_to_fb_messages fb_messages, replace '#generic.fb_first_name', user_data.first_name
        else
          resolve fb_messages
    else
      resolve fb_messages

send_queue = ({fb_messages, fb_message:original_fb_message, bot}) ->
  cumulative_wait = 0
  fb_messages = await swap_in_user_name {fb_messages, fb_message:original_fb_message}
  fb_messages.forEach (message) ->
    do (bot, original_fb_message, message, cumulative_wait) ->
      setTimeout () ->
        bot.reply original_fb_message, message
      , cumulative_wait
    cumulative_wait += df_to_messenger.msec_delay message

process_df_response_into_fb_messages = ({fb_message, df_response, bot}) ->
  df_messages = df_response.result.fulfillment.messages
  fb_messages = df_to_messenger.formatter df_messages
  send_queue {fb_messages, fb_message, bot}

tell_me_more = ({fb_message, bot}) ->
  tell_me_more_content = fb_message.text.match(/^tell_me_more: ?(.*)/i)?[1]
  fb_messages = df_to_messenger.formatter helpers.df_message_format tell_me_more_content
  send_queue {fb_messages, fb_message, bot}

check_user_type = ({fb_message, bot}) ->
  botkit.storage.users.get fb_message.user, (err, user_data) ->
    if user_data.user_type?
      bus.emit 'user returns with type set', {fb_message, bot, user_type:user_data.user_type}
    else
      bus.emit 'brand new user starts', {fb_message, bot}

check_session = ({fb_message, df_response, bot, df_session}) ->
  botkit.storage.users.get fb_message.user, (err, user_data) ->
    if user_data.last_session_id is df_session
      process_df_response_into_fb_messages {fb_message, df_response, bot}
    else
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
  event =
    if is_get_started_postback fb_message then 'postback: get started'
    else if is_tell_me_more_postback fb_message then 'postback: tell me more'
    else if is_follow_up_postback fb_message then 'postback: follow up'
    else 'message from user'
  bus.emit event, {fb_message, bot}


module.exports = {
  process_df_response_into_fb_messages
  tell_me_more
  check_user_type
  check_session
}
