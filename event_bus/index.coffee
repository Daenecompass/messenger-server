EventEmitter = require('eventemitter2').EventEmitter2
chalk = require 'chalk'

raven = require '../helpers/error-logging'


bus = new EventEmitter
  wildcard: true

bus.onAny (event, payload) ->
  if event.match /^error/i
    error_message = "Bus: #{event}"
    if payload? then error_message += ". #{payload}"
    console.log chalk.red error_message
    raven.captureException new Error error_message
  else
    console.log chalk.green "Bus: #{event}"


module.exports = bus
