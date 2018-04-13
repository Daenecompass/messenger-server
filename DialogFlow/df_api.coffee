# https://dialogflow.com/docs/reference/agent/contexts

request = require 'request'

send_context = (session, context, callback) ->
  url = "https://api.dialogflow.com/v1/contexts?sessionId=#{session}"
  headers =
    Authorization: "Bearer #{process.env.dialogflow_client_token}"
    'Content-Type': 'application/json'
  body = context

  request.post
    url: url
    body: JSON.stringify body, null, 4
    headers: headers
  , (err, r, body) ->
    console.log body
    callback

module.exports =
  send_context: send_context
