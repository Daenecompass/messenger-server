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

persistent_menu = require './persistent_menu.json'
require '../ngrok' if ngrok_subdomain and ngrok_authtoken

# storage = require('botkit-storage-mongo')
#   mongoUri: mongo_conn_string

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


controller.ready () ->
  bot = await controller.spawn()
  res = await bot.api.callAPI '/me/messenger_profile', 'delete', fields: [ 'persistent_menu', 'get_started' ]
  console.log('results of delete menu & get started', res)
  res = await bot.api.callAPI '/me/messenger_profile', 'post',
    persistent_menu: [ persistent_menu ]
    get_started: payload: 'GET_STARTED'
  console.log('results of set menu & get started payload', res)


module.exports = controller
