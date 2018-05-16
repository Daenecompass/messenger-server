EventEmitter = require('eventemitter2').EventEmitter2
chalk = require 'chalk'

bus = new EventEmitter
  wildcard: true

bus.on '*', () ->
  if @event.match /^error/i
    console.log chalk.red "Bus: #{@event}"
  else
    console.log "Bus: #{@event}"

module.exports = bus
