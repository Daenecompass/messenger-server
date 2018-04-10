bus = require '../event_bus'
dialogflow_botkit = require('api-ai-botkit') process.env.dialogflow_client_token
helpers = require '../helpers'

no_speech_in_response = (df_response) ->
  df_response.result.fulfillment.messages.every (message) -> message.speech is ''

dialogflow_botkit.all (fb_message, df_response, bot) ->
  if no_speech_in_response df_response
    bus.emit 'message from dialogflow without speech in it'
  else
    bus.emit 'message from dialogflow', fb_message, df_response, bot

module.exports =
  process: dialogflow_botkit.process

  interview_user: (fb_message, bot) ->
    fb_message.text = 'INTERVIEW_USER_INTENT'
    dialogflow_botkit.process fb_message, bot

  welcome_returning_user: (fb_message, bot) ->
    fb_message.text = 'RETURNING_USER_GREETING_INTENT'
    dialogflow_botkit.process fb_message, bot

  set_user_type: (fb_message, bot, user_type) ->
    fb_message.text = helpers.user_type_to_intent[user_type]
    dialogflow_botkit.process fb_message, bot
