{ fb_page_token } = process.env

FB = require 'fb'

FB.setAccessToken fb_page_token


fields = [ 'first_name', 'last_name', 'profile_pic' ] 

get_facebook_profile = (fb_user_id, cb) ->
  new Promise (resolve, reject) ->
    FB.api fb_user_id.toString(), 'get', fields: fields, (fb_user) ->
      if not fb_user
        reject new Error('Facebook user not found')
      if fb_user.error
        reject cb fb_user.error
      resolve fb_user


send_typing = (fb_message) ->
  FB.api '/me/messages', 'post',
    recipient: id: fb_message.user
    sender_action: 'typing_on'


module.exports =
  get_facebook_profile: get_facebook_profile
  send_typing: send_typing