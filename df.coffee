EventEmitter = require('events').EventEmitter
inherits = require('util').inherits

DF = () ->
DF.prototype =
  handle: (fb_message) ->
    console.log "* Sending regular user message (#{fb_message}) to DialogFlow"
  follow_up: (fb_message) ->
    console.log "* Stripping out the fu tag from #{fb_message}, sending the rest to DialogFlow"

inherits DF, EventEmitter

module.exports = DF
