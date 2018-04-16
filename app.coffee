require('dotenv').load()

bus = require './event_bus'

df = require './DialogFlow'   # connects to DialogFlow agent; persists DF state across sessions
fb = require './FBMessenger'  # connects to Messenger; receives messages from user; formats & sends messages to user

bus.on 'message from user', df.process_fb_message
bus.on 'message from dialogflow', fb.check_session
bus.on 'message from dialogflow', fb.process_df_response_into_fb_messages
bus.on 'postback: get started', fb.check_user_type
bus.on 'postback: tell me more', fb.tell_me_more
bus.on 'postback: follow up', df.follow_up
bus.on 'brand new user starts', df.interview_user
bus.on 'user session changed', df.set_user_type
bus.on 'user returns with type set', df.set_user_type
bus.on 'user returns with type set', df.welcome_returning_user
