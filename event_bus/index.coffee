# Event bus plus sends errors to Sentry, both explicitly with captureException, and any other fatal errors

EventEmitter = require('eventemitter2').EventEmitter2
chalk = require 'chalk'
Sentry = require '@sentry/node'

{ Js } = require '../helpers'

{ 
  sentry_dsn
  NODE_ENV
} = process.env

Sentry.init
  dsn: sentry_dsn
  environment: NODE_ENV

bus = new EventEmitter
  wildcard: true

bus.onAny (event, payload) ->
  if event.match /^error/i
    error_message = "Bus: #{event}"
    if payload? then error_message += ". #{payload}"
    console.log chalk.red error_message
    Sentry.captureException new Error error_message
  else
    console.log chalk.green "Bus: #{event}"
    if payload? and (NODE_ENV is 'development')
      console.log 'Event payload:', Object.keys(payload)
      if payload.message?
        console.log 'message', Js payload.message
      else if payload.fb_message?
        console.log 'fb_message.message', Js payload.fb_message?.message
      if payload.df_result?.fulfillmentMessages?
        console.log 'df_result.fulfillmentMessages', Js payload.df_result?.fulfillmentMessages

bus.emit 'STARTUP: Sending errors to ' + process.env.sentry_dsn


module.exports = bus
