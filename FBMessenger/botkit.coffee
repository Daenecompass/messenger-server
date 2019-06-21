{ Botkit } = require 'botkit'
{ FacebookAdapter, FacebookEventTypeMiddleware } = require 'botbuilder-adapter-facebook'

persistent_menu = require './persistent_menu.json'
require '../ngrok' if process.env.ngrok_subdomain and process.env.ngrok_authtoken

{mongoatlas_user, mongoatlas_password, mongoatlas_db_string} = process.env
storage = require('botkit-storage-mongo')
  mongoUri: "mongodb://#{mongoatlas_user}:#{mongoatlas_password}@#{mongoatlas_db_string}"

adapter = new FacebookAdapter
    verify_token: process.env.fb_verify_token
    access_token: process.env.fb_page_token
    app_secret: process.env.fb_app_secret

adapter.use new FacebookEventTypeMiddleware()

controller = new Botkit
  debug: process.env.NODE_ENV is 'development' ? true : false
  validate_requests: true
  # receive_via_postback: true
  webhook_uri: '/facebook/receive'
  adapter: adapter
  storage: storage


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
