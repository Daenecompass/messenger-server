EventEmitter = require('eventemitter2').EventEmitter2

bus = new EventEmitter
  wildcard: true

bus.on '*', () -> console.log "Bus: #{@event}"

module.exports = bus
