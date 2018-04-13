bus = require '../event_bus'
dialogflow_botkit = require('api-ai-botkit') process.env.dialogflow_client_token
helpers = require '../helpers'
df_api = require './df_api'

no_speech_in_response = (df_response) ->
  df_response.result.fulfillment.messages.every (message) -> message.speech is ''

dialogflow_botkit.all (fb_message, df_response, bot) ->
  df_session = dialogflow_botkit.sessionIds[fb_message.user]
  if no_speech_in_response df_response
    bus.emit 'message from dialogflow without speech in it'
  else
    bus.emit 'message from dialogflow', {fb_message, df_response, bot, df_session}

module.exports =
  process: ({fb_message, bot}) -> dialogflow_botkit.process fb_message, bot

  interview_user: ({fb_message, bot}) ->
    fb_message.text = 'INTERVIEW_USER_INTENT'
    dialogflow_botkit.process fb_message, bot

  welcome_returning_user: ({fb_message, bot}) ->
    fb_message.text = 'RETURNING_USER_GREETING_INTENT'
    dialogflow_botkit.process fb_message, bot

  follow_up: ({fb_message, bot}) ->
    fb_message.text = fb_message.text.replace helpers.follow_up_regex, ''
    dialogflow_botkit.process fb_message, bot

  set_user_type: ({fb_message, bot, user_type, df_session}) ->
    # this needs to handle those multi-contexts, like boadinghouse-and-social
    # may need to clear other contexts

    context =
      [
        lifespan: 5
        name: user_type
      ,
        lifespan: 5
        name: 'generic'
        parameters:
          fb_first_name: 'Carmelite Nun the First'
      ]

    df_api.send_context df_session, context, bus.emit 'context sent to dialogflow'
