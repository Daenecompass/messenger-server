EventEmitter = require('events').EventEmitter
inherits = require('util').inherits

DF = () ->
DF.prototype =
  handle: (fb_message) ->
    console.log "* Sending regular user message (#{fb_message}) to DialogFlow"
  follow_up: (fb_message) ->
    console.log "* Stripping out the fu tag from #{fb_message}, sending the rest to DialogFlow"
  get_started: () ->
    console.log "* Check whether new or returning user, and ask DialogFlow for the relevant intent; send DialogFlow context if returning user"

inherits DF, EventEmitter

module.exports = DF
