is_balanced = require 'is-balanced'

bus = require '../event_bus'
{ regex, Js } = require '../helpers'
{ df_query, send_context } = require './df_api_v2'


no_speech_in_response = (df_response) ->
  df_response.result.fulfillment.messages.every (message) -> message.speech is ''


response_wellformed = (df_result) ->
  remove_smiley = (text) -> text.replace /:\)/, ''
  df_result.fulfillmentMessages.every (message) ->
    speech = ''
    if message.speech? then speech = remove_smiley message.speech
    balanced = is_balanced speech, '{[(', '}])'
    more_wrong = speech?.match /\[more:.*\]/i
    follow_up_right =
      if speech?.match(/\[FU/i)
        speech.match /\[FU:.+:.+\]/i
      else
        true
    balanced and not more_wrong and follow_up_right


process_fb_message = ({ fb_message, bot }) ->
  df_result = await df_query
    query: fb_message.text
    session_id: fb_message.sender.id
    bot: bot
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
  switch
    when df_result.action?.match /Interviewuser\..*/
      bus.emit 'message from user: user_type interview', {
        user_type: df_result.action.match(/Interviewuser\.(.*)/)[1]
        fb_message
      }
    when df_result.action is 'feedback' and df_result.parameters?.fields?.feedback?.stringValue?.length
      bus.emit 'user feedback received', {
        user_id: fb_message.sender.id
        feedback: df_result.parameters.fields.feedback.stringValue
      }


interview_user = ({ fb_message, bot }) ->
  fb_message.text = 'INTERVIEW_USER_INTENT'
  process_fb_message { fb_message, bot }


welcome_returning_user = ({ fb_message, bot }) ->
  fb_message.text = 'RETURNING_USER_GREETING_INTENT'
  process_fb_message { fb_message, bot }


follow_up = ({ fb_message, bot }) ->
  fb_message.text = fb_message.text.replace regex.follow_up, ''
  process_fb_message { fb_message, bot }


card_button = ({ fb_message, bot }) ->
  fb_message.text = fb_message.text.replace regex.card_button, ''
  process_fb_message { fb_message, bot }


qr_follow_up = ({ fb_message, bot }) ->
  fb_message.text = fb_message.quick_reply?.payload.replace regex.follow_up, ''
  process_fb_message { fb_message, bot }


set_user_type = ({ user_type, df_session, fb_first_name }) ->
  if user_type?
    send_context
      session_id: df_session
      user_type: user_type
      fb_first_name: fb_first_name
      on_success: () -> bus.emit 'context sent to dialogflow'
      on_failure: () -> bus.emit 'Error: problem communicating with Dialogflow'


module.exports = {
  process_fb_message
  interview_user
  welcome_returning_user
  follow_up
  card_button
  qr_follow_up
  set_user_type
  # for testing
  response_wellformed
}
