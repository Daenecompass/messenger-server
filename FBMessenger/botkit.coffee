{
  fb_verify_token
  fb_page_token
  fb_app_secret
  ngrok_subdomain
  ngrok_authtoken
  mongoatlas_conn_string
  NODE_ENV
  google_creds
} = process.env
credentials = JSON.parse google_creds


{ Botkit } = require 'botkit'
{ FacebookAdapter, FacebookEventTypeMiddleware } = require 'botbuilder-adapter-facebook'

persistent_menu = require './persistent_menu.json'
require '../ngrok' if ngrok_subdomain and ngrok_authtoken

# {mongoatlas_user, mongoatlas_password, mongoatlas_db_string} = process.env
# storage = require('botkit-storage-mongo')
#   mongoUri: "mongodb://#{mongoatlas_user}:#{mongoatlas_password}@#{mongoatlas_db_string}"

adapter = new FacebookAdapter
  verify_token: fb_verify_token
  access_token: fb_page_token
  app_secret: fb_app_secret
  validate_requests: true
  receive_via_postback: true

# adapter.use new FacebookEventTypeMiddleware()

controller = new Botkit
  debug: NODE_ENV is 'development'
  webhook_uri: '/facebook/receive'
  adapter: adapter
  # storage: storage


# fbuser = require('botkit-middleware-fbuser')
#   accessToken: process.env.fb_page_token
#   fields: ['first_name', 'last_name', 'profile_pic']
#   logLevel: 'error'
#   expire: 24 * 60 * 60 * 1000 # refresh profile info every 24 hours
#   storage: controller.storage

# controller.middleware.receive.use fbuser.receive

# bot = controller.spawn()

# controller.api.messenger_profile.get_started 'GET_STARTED'
# controller.api.thread_settings.menu [persistent_menu]

module.exports = controller
