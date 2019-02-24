mongo = require './db'


module.exports =
  from_fb: ({fb_message}) ->
    console.log 'timestamp', Date.now()
    console.log 'user id', fb_message.user
    console.log 'said', fb_message.text


  from_df: ({fb_message, df_response, df_session}) ->
    console.log 'timestamp', Date.now()
    console.log 'user id', fb_message.user
    console.log 'df session', df_session
    console.log 'df messages', df_response.result?.fulfillment?.messages


  to_fb: ({fb_message, message}) ->
    console.log 'timestamp', Date.now()
    console.log 'user id', fb_message.user
    console.log 'message', message
