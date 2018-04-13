module.exports =
  tell_me_more_regex: /^tell_me_more: ?/i
  follow_up_regex: /^follow_up: ?/i
  phone_web_tag_regex: /\[(.*?(0800|http).*?)\]/i
  follow_up_tag_regex: /\[fu: ?(.*?): ?(.*?)\]/i

  remove_tell_me_more_in_fb_message: (fb_message) ->
    console.log fb_message
    fb_message.text = fb_message.text.replace @tell_me_more_regex, ''
    fb_message

  user_type_to_intent:
    'landlord': 'SET_LANDLORD_CONTEXT_INTENT'
    'private': 'SET_PRIVATE_CONTEXT_INTENT'
    'social-housing': 'SET_SOCIAL-HOUSING_CONTEXT_INTENT'
    'boardinghouse': 'SET_BOARDINGHOUSE_CONTEXT_INTENT'

  df_message_format: (text) ->
    [type: 0, speech: text]
