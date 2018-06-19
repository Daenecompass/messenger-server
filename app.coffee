require './env'
raven = require './helpers/error-logging'

raven.context () ->
  bus = require './event_bus'

  df = require './Dialogflow'   # connects to Dialogflow agent (via botkit & DF api)
  fb = require './FBMessenger'  # connects to Messenger; receives messages from user
                                # formats & sends messages to user; persists state across sessions

  # events from FBMessenger
  bus.on 'message from user', df.process_fb_message
  bus.on 'postback: get started', fb.check_user_type
  bus.on 'postback: tell me more', fb.tell_me_more
  bus.on 'postback: follow up', df.follow_up
  bus.on 'quick reply: follow up', df.qr_follow_up
  bus.on 'user session changed', df.set_user_type
  bus.on 'user returns with type set', df.set_user_type
  bus.on 'user returns with type set', df.welcome_returning_user
  bus.on 'user with unknown type starts', df.interview_user

  # events from Dialogflow
  bus.on 'message from dialogflow', fb.check_session
  bus.on 'message from dialogflow', fb.process_df_response_into_fb_messages
  bus.on 'message from user: user_type interview', fb.store_user_type
