# Modified from https://github.com/googleapis/nodejs-dialogflow
# Auth from https://medium.com/@tzahi/how-to-setup-dialogflow-v2-authentication-programmatically-with-node-js-b37fa4815d89

dialogflow = require 'dialogflow'


projectId = 'rentbot-apiv2'

config = credentials: JSON.parse(process.env.google_creds)


# query: text to send to Dialogflow
# sessionId: unique ID to keep track of session - Messenger userid, in this case
# bot: botkit object
module.exports = ({query, sessionId, bot}) ->
  sessionClient = new dialogflow.SessionsClient(config)
  sessionPath = sessionClient.sessionPath projectId, sessionId

  request =
    session: sessionPath
    queryInput:
      text:
        text: query,
        languageCode: 'en-US'

  responses = await sessionClient.detectIntent request
  responses[0].queryResult
