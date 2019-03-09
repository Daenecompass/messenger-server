# Modified from https://github.com/googleapis/nodejs-dialogflow

dialogflow = require 'dialogflow'


projectId = 'rentbot-apiv2'

# query: text to send to Dialogflow
# sessionId: unique ID to keep track of session - Messenger userid, in this case
# bot: botkit object
module.exports = ({query, sessionId, bot}) ->
  sessionClient = new dialogflow.SessionsClient()
  sessionPath = sessionClient.sessionPath projectId, sessionId

  request =
    session: sessionPath
    queryInput:
      text:
        text: query,
        languageCode: 'en-US'

  responses = await sessionClient.detectIntent request
  # console.log 'df_api_v2 (responses): ', responses
  result = responses[0].queryResult
  result
