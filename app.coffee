require './env'
raven = require './helpers/error-logging'

raven.context () ->
  bus = require './event_bus'

  df = require './Dialogflow'   # connects to Dialogflow agent (via botkit & DF api)
  fb = require './FBMessenger'  # connects to Messenger; receives messages from user
                                # formats & sends messages to user; persists state across sessions
  logger = require './logger'

  bus
  # events from FBMessenger
    .on 'message from user', df.process_fb_message
    .on 'message from user', logger.from_fb
    .on 'postback: get started', fb.check_user_type
    .on 'postback: get started', logger.from_fb
    .on 'postback: tell me more', fb.tell_me_more
    .on 'postback: tell me more', logger.from_fb
    .on 'postback: follow up', df.follow_up
    .on 'quick reply: follow up', df.qr_follow_up
    .on 'quick reply: follow up', logger.from_fb
    .on 'user session changed', df.set_user_type
    .on 'user returns with type set', df.set_user_type
    .on 'user returns with type set', df.welcome_returning_user
    .on 'user with unknown type starts', df.interview_user
    .on 'user feedback received', logger.feedback

  # events from Dialogflow
    .on 'message from dialogflow', fb.check_session
    .on 'message from dialogflow', logger.from_df
    .on 'message from dialogflow', fb.process_df_response_into_fb_messages
    .on 'message from user: user_type interview', fb.store_user_type

  # events to FBMessenger
    .on 'message to user', logger.to_fb
