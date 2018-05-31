EventEmitter = require('eventemitter2').EventEmitter2
chalk = require 'chalk'
raven = require '../helpers/error-logging'

bus = new EventEmitter
  wildcard: true

bus.on '*', () ->
  if @event.match /^error/i
    console.log chalk.red "Bus: #{@event}"
    raven.captureException new Error @event
  else
    console.log "Bus: #{@event}"

module.exports = bus
