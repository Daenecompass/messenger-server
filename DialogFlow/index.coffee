bus = require '../event_bus'
dialogflow_botkit = require('api-ai-botkit') process.env.dialogflow_client_token
{follow_up_regex} = require '../helpers'
df_api = require './df_api'
is_balanced = require 'is-balanced'

no_speech_in_response = (df_response) ->
  df_response.result.fulfillment.messages.every (message) -> message.speech is ''

response_malformed = (df_response) ->
  not df_response.result.fulfillment.messages.every (message) ->
    is_balanced(message.speech, '{[(', ')]}') and not message.speech.match /\[.*more:.*\]/i

process_fb_message = ({fb_message, bot}) -> dialogflow_botkit.process fb_message, bot

interview_user = ({fb_message, bot}) ->
  fb_message.text = 'INTERVIEW_USER_INTENT'
  dialogflow_botkit.process fb_message, bot

welcome_returning_user = ({fb_message, bot}) ->
  fb_message.text = 'RETURNING_USER_GREETING_INTENT'
  dialogflow_botkit.process fb_message, bot

follow_up = ({fb_message, bot}) ->
  fb_message.text = fb_message.text.replace follow_up_regex, ''
  dialogflow_botkit.process fb_message, bot

qr_follow_up = ({fb_message, bot}) ->
  fb_message.text = fb_message.quick_reply?.payload.replace follow_up_regex, ''
  dialogflow_botkit.process fb_message, bot

set_user_type = ({fb_message, bot, user_type, df_session, df_response, fb_first_name}) ->
  df_api.send_context {
    session: df_session
    user_type: user_type
    fb_first_name: fb_first_name
    on_success: bus.emit 'context sent to dialogflow', {fb_message, bot, user_type, df_response}
  }

user_type_interview_event = (fb_message, df_response, bot) ->
  bus.emit 'message from user: user_type interview', {df_response, fb_message}

dialogflow_botkit
  .all (fb_message, df_response, bot) ->
    if no_speech_in_response df_response
      bus.emit 'error: message from dialogflow without speech in it'
    else if response_malformed df_response
      bus.emit 'error: message from dialogflow is malformed'
    else
      df_session = dialogflow_botkit.sessionIds[fb_message.user]
      bus.emit 'message from dialogflow', {fb_message, df_response, bot, df_session}
  .action 'Interviewuser.landlord', user_type_interview_event
  .action 'Interviewuser.boardinghouse', user_type_interview_event
  .action 'Interviewuser.private', user_type_interview_event
  .action 'Interviewuser.social-housing', user_type_interview_event


module.exports = {
  process_fb_message
  interview_user
  welcome_returning_user
  follow_up
  qr_follow_up
  set_user_type
}
