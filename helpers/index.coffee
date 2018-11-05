module.exports =
  regex:
    tell_me_more: /^tell_me_more: ?/i
    follow_up: /^follow_up: ?/i
    button_tag: /\[.*?(0800|111|0[0-9]|http).*?\]/ig
    newline_button_tag: /(\n)(\[(.+(0800|111|0[0-9]|http).+)\])/ig
    phone: /(.+) (111|0800.+|0[0-9].+)/
    url: /(.+) (https?:\/\/.+)/i
    messenger_url: /(.+) (https?:\/\/m\.me\/.+)/i
    pdf_url: /(.+) (https?:\/\/.+\.pdf)/i
    map_url: /(.+) (https?:\/\/.+\/maps\/.+)/i
    follow_up_tag: /\[fu: ?(.*?): ?(.*?)\]/i

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
