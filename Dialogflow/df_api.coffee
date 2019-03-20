# https://dialogflow.com/docs/reference/agent/contexts

request = require 'request'

user_type_to_contexts =
  'landlord': ['landlord']
  'private': ['private']
  'boardinghouse': ['boardinghouse', 'boardinghouse-or-social-housing']
  'social-housing': ['socialhousing', 'boardinghouse-or-social-housing']
  null: []
  '': []

send_context = ({session, user_type, fb_first_name, on_success, on_failure}) ->
  # may need to clear other contexts
  contexts = []
  if user_type
    contexts = user_type_to_contexts[user_type].map (context) ->
      name: context
      lifespan: 999
  contexts.push
    name: 'generic'
    parameters:
      fb_first_name: fb_first_name
    lifespan: 999

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
    if err
      on_failure err
    else
      on_success

module.exports =
  send_context: send_context
