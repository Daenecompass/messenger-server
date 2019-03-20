is_balanced = require 'is-balanced'

bus = require '../event_bus'
{regex, Js} = require '../helpers'
df_api = require './df_api'
df_api_v2 = require './df_api_v2'


no_speech_in_response = (df_response) ->
  df_response.result.fulfillment.messages.every (message) -> message.speech is ''


response_wellformed = (df_result) ->
  remove_smiley = (text) -> text.replace /:\)/, ''
  df_result.fulfillmentMessages.every (message) ->
    speech = ''
    if message.speech? then speech = remove_smiley message.speech
    balanced = is_balanced(speech, '{[(', '}])')
    more_wrong = speech?.match /\[more:.*\]/i
    follow_up_right =
      if speech?.match(/\[FU/i)
        speech.match /\[FU:.+:.+\]/i
      else
        true
    balanced and not more_wrong and follow_up_right


process_fb_message = ({fb_message, bot}) ->
  # TODO: check for long messages
  df_result = await df_api_v2
    query: fb_message.text
    bot: bot
    sessionId: fb_message.sender.id

  switch
    when not response_wellformed df_result
      bus.emit 'error: message from dialogflow is malformed', "Message text: #{fb_message.message.text}"
    else
      bus.emit 'message from dialogflow', {
        fb_message
        df_result
        bot
        df_session: fb_message.sender.id
      }

# TODO:
# dialogflow_botkit
#   .all (fb_message, df_response, bot) ->
#     if no_speech_in_response df_response
#       bus.emit 'error: message from dialogflow without speech in it'
#     else
#       if not response_wellformed df_response
#         bus.emit 'error: message from dialogflow is malformed', "Message text: #{fb_message.message.text}"
#       df_session = dialogflow_botkit.sessionIds[fb_message.user]
#       bus.emit 'message from dialogflow', {fb_message, df_response, bot, df_session}
#   .action 'Interviewuser.landlord', user_type_interview_event
#   .action 'Interviewuser.boardinghouse', user_type_interview_event
#   .action 'Interviewuser.private', user_type_interview_event
#   .action 'Interviewuser.social-housing', user_type_interview_event


interview_user = ({fb_message, bot}) ->
  fb_message.text = 'INTERVIEW_USER_INTENT'
  process_fb_message {fb_message, bot}


welcome_returning_user = ({fb_message, bot}) ->
  fb_message.text = 'RETURNING_USER_GREETING_INTENT'
  process_fb_message {fb_message, bot}


follow_up = ({fb_message, bot}) ->
  fb_message.text = fb_message.text.replace regex.follow_up, ''
  process_fb_message {fb_message, bot}


qr_follow_up = ({fb_message, bot}) ->
  fb_message.text = fb_message.quick_reply?.payload.replace regex.follow_up, ''
  process_fb_message {fb_message, bot}


set_user_type = ({fb_message, bot, user_type, df_session, df_response, fb_first_name}) ->
  df_api.send_context {
    session: df_session
    user_type: user_type
    fb_first_name: fb_first_name
    on_success: bus.emit 'context sent to dialogflow', {fb_message, bot, user_type, df_response}
    on_failure: (err) -> bus.emit 'Error: problem communicating with Dialogflow: ', err
  }


user_type_interview_event = (fb_message, df_response, bot) ->
  bus.emit 'message from user: user_type interview', {df_response, fb_message}


module.exports = {
  process_fb_message
  interview_user
  welcome_returning_user
  follow_up
  qr_follow_up
  set_user_type
  # for testing
  response_wellformed
}
