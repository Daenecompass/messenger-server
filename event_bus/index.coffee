EventEmitter = require('eventemitter2').EventEmitter2
chalk = require 'chalk'
raven = require '../helpers/error-logging'

bus = new EventEmitter
  wildcard: true

bus.on '*', (payload) ->
  if @event.match /^error/i
    console.log chalk.red "Bus: #{@event}"
    if payload? then console.log chalk.red payload
    raven.captureException new Error @event
  else
    console.log "Bus: #{@event}"

module.exports = bus
