mongoose = require 'mongoose'

bus = require '../event_bus'


mongoose.connect 'mongodb://localhost/rentbot-local', useNewUrlParser: true
  .then (m) ->
    bus.emit "STARTUP: connected to database #{m.connections[0].host}/#{m.connections[0].name}"

Schema = mongoose.Schema
ObjectId = mongoose.Schema.Types.ObjectId

UserSchema = new Schema
  _id: String
  feedback: [
    feedback: String
    created_at:
      type: Date
      default: Date.now
  ]
  created_at:
    type: Date
    default: Date.now

EventSchema = new Schema
  created_at:
    type: Date
    default: Date.now
  event_type:
    type: String
    required: true
  user:
    type: String
    ref: 'User'
  user_said: String
  user_quick_reply: String
  bot_said: Object
  df_session: String
  df_messages: Array
  df_intent: String
  df_confidence: Number


module.exports =
  User: mongoose.models.User or mongoose.model 'User', UserSchema
  Event: mongoose.models.Event or mongoose.model 'Event', EventSchema
