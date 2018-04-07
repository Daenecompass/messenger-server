EventEmitter = require('events').EventEmitter
dialogflow_botkit = require('api-ai-botkit') process.env.dialogflow_client_token
fb = require '../FBMessenger'

dialogflow_botkit.all fb.handle
  # lib.delegate_df_messages bot, fb_message, df_response.result.fulfillment.messages

df =
  handle: (fb_message, bot) ->
    # console.log "* Sending regular user message (#{fb_message}) to DialogFlow"
    dialogflow_botkit.process fb_message, bot
  follow_up: (fb_message) ->
    console.log "* Stripping out the fu tag from #{fb_message}, sending the rest to DialogFlow"
  get_started: () ->
    console.log "* Check whether new or returning user, and ask DialogFlow for the relevant intent; send DialogFlow context if returning user"

Object.assign df, EventEmitter.prototype

module.exports = df
