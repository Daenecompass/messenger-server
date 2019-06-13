# Event bus plus sends errors to Sentry, both explicitly with captureException, and any other fatal errors

EventEmitter = require('eventemitter2').EventEmitter2
chalk = require 'chalk'
Sentry = require '@sentry/node'

Sentry.init
    dsn: process.env.sentry_dsn
    environment: process.env.NODE_ENV
    debug: true


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

bus.emit 'STARTUP: Sending errors to ' + process.env.sentry_dsn


module.exports = bus
