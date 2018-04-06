FBMessenger = require './FBMessenger'
DialogFlow = require './DialogFlow'

fb = new FBMessenger()  # connects to Messenger; receives messages from user; formats & sends messages to user
df = new DialogFlow()   # connects to DialogFlow agent; persists DF state across sessions

fb.on 'regular user message', df.handle
fb.on 'tell me more postback', fb.tell_me_more
fb.on 'follow up postback', df.follow_up
fb.on 'get started postback', df.get_started

df.on 'response', fb.handle

# pretending to be live usage
fb.emit 'get started postback'                                            # user clicks get started
fb.emit 'regular user message', 'how do I end a tenancy?'                 # user asks bot question
df.emit 'response', 'Here\'s how you end a tenancy… [more] Extra info'    # DF guesses intent, sends back response
fb.emit 'tell me more postback', 'TELL_ME_MORE: Extra info'               # user clicks More info button
fb.emit 'regular user message', 'My house is damp'                        # user asks bot question
df.emit 'response', 'Sorry about that [FU: Want to know about mold?: What do I do about mold?]'
                                                                          # DF sends back respons, including follow-up question with button
fb.emit 'follow up postback', 'FOLLOW_UP: What do I do about mold?'       # user clicks button
df.emit 'response', 'Here\'s what I know about mold'                      # DF sends back response

# OUTPUT:
# * Check whether new or returning user, and ask DialogFlow for the relevant intent; send DialogFlow context if returning user
# * Sending regular user message (how do I end a tenancy?) to DialogFlow
# * Dealing with DialogFlow's response (Here's how you end a tenancy… [more] Extra info) – splitting it up and queuing it to send, formatting buttons etc
# * Formatting tell me more portion of postback (TELL_ME_MORE: Extra info) and sending it back to Messenger…
# * Sending regular user message (My house is damp) to DialogFlow
# * Dealing with DialogFlow's response (Sorry about that [FU: Want to know about mold?: What do I do about mold?]) – splitting it up and queuing it to send, formatting buttons etc
# * Stripping out the fu tag from FOLLOW_UP: What do I do about mold?, sending the rest to DialogFlow
# * Dealing with DialogFlow's response (Here's what I know about mold) – splitting it up and queuing it to send, formatting buttons etc
