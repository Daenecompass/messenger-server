Botkit = require 'botkit'

mongoStorage = require('botkit-storage-mongo')
  mongoUri: "mongodb://#{process.env.mongoatlas_user}:#{process.env.mongoatlas_password}@rentbot-shard-00-00-dw7r3.mongodb.net:27017,rentbot-shard-00-01-dw7r3.mongodb.net:27017,rentbot-shard-00-02-dw7r3.mongodb.net:27017/test?ssl=true&replicaSet=rentbot-shard-0&authSource=admin"

controller = Botkit.facebookbot
  debug: true
  # log: true
  access_token: process.env.fb_page_token
  verify_token: process.env.fb_verify_token
  app_secret: process.env.fb_app_secret
  validate_requests: true
  receive_via_postback: true
  storage: mongoStorage

fbuser = require('botkit-middleware-fbuser')
  accessToken: process.env.fb_page_token
  fields: ['first_name', 'last_name', 'locale', 'profile_pic','timezone','gender','is_payment_enabled']
  logLevel: 'error'
  expire: 24 * 60 * 60 * 1000 # refresh profile info every 24 hours
  storage: controller.storage
controller.middleware.receive.use fbuser.receive

bot = controller.spawn()

port = process.env.PORT or 3000
controller.setupWebserver port, (err, webserver) ->
  controller.createWebhookEndpoints webserver, bot, () ->
    require '../ngrok' if process.env.ngrok_subdomain and process.env.ngrok_authtoken

module.exports = controller
