module.exports =
  tell_me_more_regex: /^tell_me_more: ?/i
  follow_up_regex: /^follow_up: ?/i
  button_tag_regex: /\[.*?(0800|111|0[0-9]|http).*?\]/ig
  newline_button_tag_regex: /(\n)(\[(.+(0800|111|0[0-9]|http).+)\])/ig
  phone_regex: /(.+) (111|0800.+|0[0-9].+)/
  url_regex: /(.+) (https?:\/\/.+)/i
  messenger_url_regex: /(.+) (https?:\/\/m\.me\/.+)/i
  pdf_url_regex: /(.+) (https?:\/\/.+\.pdf)/i
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
