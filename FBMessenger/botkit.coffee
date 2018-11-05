Botkit = require 'botkit'

mongoStorage = require('botkit-storage-mongo')
  mongoUri: "mongodb://#{process.env.mongoatlas_user}:#{process.env.mongoatlas_password}@#{process.env.mongoatlas_db_string}"

controller = Botkit.facebookbot
  debug: process.env.NODE_ENV is 'development' ? true : false
  # log: true
  access_token: process.env.fb_page_token
  verify_token: process.env.fb_verify_token
  app_secret: process.env.fb_app_secret
  validate_requests: true
  receive_via_postback: true
  storage: mongoStorage

bot = controller.spawn()

port = process.env.PORT or 3000
controller.setupWebserver port, (err, webserver) ->
  controller.createWebhookEndpoints webserver, bot, () ->
    require '../ngrok' if process.env.ngrok_subdomain and process.env.ngrok_authtoken

controller.api.messenger_profile.get_started 'GET_STARTED'

module.exports = controller
