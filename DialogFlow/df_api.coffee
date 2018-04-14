# https://dialogflow.com/docs/reference/agent/contexts

request = require 'request'

send_context = ({session, contexts, on_success, on_failure}) ->
  url = "https://api.dialogflow.com/v1/contexts?sessionId=#{session}"
  headers =
    Authorization: "Bearer #{process.env.dialogflow_client_token}"
    'Content-Type': 'application/json'
  body = contexts

  request.post
    url: url
    body: JSON.stringify body, null, 4
    headers: headers
  , (err, r, body) ->
    console.log body
    if err
      on_failure
    else
      on_success

module.exports =
  send_context: send_context
