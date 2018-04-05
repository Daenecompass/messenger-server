FBMessenger = require './fb'
DialogFlow = require './df'

fb = new FBMessenger()  # connects to Messenger; receives messages from user; formats & sends messages to user
df = new DialogFlow()   # connects to DialogFlow agent; persists DF state across sessions

fb.on 'regular user message', (fb_message) -> df.handle fb_message
fb.on 'tell me more postback', (fb_message) -> fb.tell_me_more fb_message
fb.on 'follow up postback', (fb_message) -> df.follow_up fb_message
fb.on 'get started postback', (fb_message) -> df.get_started fb_message

df.on 'response', (df_response) -> fb.handle df_response

# pretending to be live usage
fb.emit 'regular user message', 'how do I end a tenancy?'                 # user asks bot question
df.emit 'response', 'Here\'s how you end a tenancy… [more] Extra info'    # DF guesses intent, sends back response
fb.emit 'tell me more postback', 'TELL_ME_MORE: Extra info'               # user clicks More info button
fb.emit 'regular user message', 'My house is damp'                        # user asks bot question
df.emit 'response', 'Sorry about that [FU: Want to know about mold?: What do I do about mold?]'
                                                                          # DF sends back respons, including follow-up question with button
fb.emit 'follow up postback', 'FOLLOW_UP: What do I do about mold?'       # user clicks button
df.emit 'response', 'Here\'s what I know about mold'                      # DF sends back response
