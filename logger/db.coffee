mongoose = require 'mongoose'

bus = require '../event_bus'


mongoose.connect 'mongodb://localhost/rentbot-local', useNewUrlParser: true
  .then (m) ->
    bus.emit "connected to database: #{m.connections[0].host}/#{m.connections[0].name}"

Schema = mongoose.Schema
ObjectId = mongoose.Schema.Types.ObjectId

Event = mongoose.model 'Event',
  event_type: String
  user: ObjectId
  user_said: String
  bot_said: String
  df_session: String
  df_messages: Array


module.exports = {
  Event
}
