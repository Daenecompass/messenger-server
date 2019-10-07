{
  fb_verify_token
  fb_page_token
  fb_app_secret
  ngrok_subdomain
  ngrok_authtoken
  mongo_conn_string
  NODE_ENV
  google_creds
} = process.env
credentials = JSON.parse google_creds

{ Botkit } = require 'botkit'
{ FacebookAdapter, FacebookEventTypeMiddleware } = require 'botbuilder-adapter-facebook'

require '../ngrok' if ngrok_subdomain and ngrok_authtoken

adapter = new FacebookAdapter
  verify_token: fb_verify_token
  access_token: fb_page_token
  app_secret: fb_app_secret
  validate_requests: true
  receive_via_postback: true

adapter.use new FacebookEventTypeMiddleware()

controller = new Botkit
  debug: NODE_ENV is 'development'
  webhook_uri: '/facebook/receive'
  adapter: adapter


send_typing = (bot, fb_message) ->
  await bot.api.callAPI '/me/messages', 'post',
    recipient: id: fb_message.user
    sender_action: 'typing_on'


module.exports = 
  botkit: controller
  send_typing: send_typing