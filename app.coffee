require('dotenv').load()

bus = require './event_bus'

df = require './DialogFlow'   # connects to DialogFlow agent; persists DF state across sessions
fb = require './FBMessenger'  # connects to Messenger; receives messages from user; formats & sends messages to user

bus.on 'message from user', df.process
bus.on 'message from dialogflow', fb.handle_very_plain_message
bus.on 'postback: get started', fb.check_user_type
bus.on 'brand new user starts', df.interview_user
bus.on 'user returns with type set', df.set_user_type
bus.on 'user returns with type set', df.welcome_returning_user
