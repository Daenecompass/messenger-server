helpers = require '../helpers'

module.exports = (fb_message, FB) ->
  if fb_message.type is 'facebook_postback'
    if fb_message.text.match helpers.tell_me_more_regex
      fb_message.text = fb_message.text.replace helpers.tell_me_more_regex, ''
      FB.handle fb_message
      # emit an event that DF module should respond to
      # lib.delegate_df_messages bot, fb_message, lib.df_message_format fb_message.text.replace lib.tell_me_more_regex
    else if fb_message.text.match helpers.follow_up_regex
      fb_message.text = fb_message.text.replace helpers.follow_up_regex, ''
      # emit an event that DF module should respond to
      # bot.startTyping fb_message, () -> dialogflow.process fb_message, bot
    else if fb_message.text.match 'GET_STARTED'
      controller.storage.users.get fb_message.user, (err, user_data) ->
        if err
          throw Error err
        else
          if user_data.user_type? then fb_message.text = 'RETURNING_USER_GREETING_INTENT'
          else fb_message.text = 'INTERVIEW_USER_INTENT'
        bot.startTyping fb_message, () -> dialogflow.process fb_message, bot
