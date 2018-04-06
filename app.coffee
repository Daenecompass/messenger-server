require('dotenv').load()
fb = require './FBMessenger'  # connects to Messenger; receives messages from user; formats & sends messages to user
df = require './DialogFlow'   # connects to DialogFlow agent; persists DF state across sessions

fb.on 'regular user message', df.handle
fb.on 'tell me more postback', fb.tell_me_more
fb.on 'follow up postback', df.follow_up
fb.on 'get started postback', df.get_started

df.on 'response', fb.handle

fake_fb_message = {}
fake_fb_message.type = 'postback'
fake_fb_message.message = 'tell_me_more: yo ho ho'
fb.emit 'tell me more postback', fake_fb_message
