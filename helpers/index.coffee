bus = require '../event_bus'


module.exports =
  regex:
    tell_me_more: /^tell_me_more: ?/i
    follow_up: /^follow_up: ?/i
    card_button: /^card_button: ?/i
    button_tag: /\[.*?(0800|111|0[0-9]|http).*?\]/ig
    whitespace_around_button_tags: /[\s]*(\[(.+(0800|111|0[0-9]|http).*)\][\s]*)/ig
    whitespace_around_first_more: /[\s]*(\[more\])[\s]*/i
    phone: /(.+?) ((?:111|0800|0[0-9])[0-9 ]*)/
    url: /(.+) (https?:\/\/.+)/i
    messenger_url: /(.+) (https?:\/\/m\.me\/.+)/i
    clm_url: /(.+) (http.*community-law-manual.*)/i
    pdf_url: /(.+) (https?:\/\/.+\.pdf)/i
    map_url: /(.+) (https?:\/\/.+\/maps\/.+)/i
    follow_up_tag: /\[fu: ?(.*?): ?(.*?)\]/i
    quick_replies_tag: /\[qr: (.+?)\]/i
    cards_tag: /\[cards?: (.+?)\]/i

  remove_empties: (arr) -> arr.filter (x) -> x isnt ''

  remove_tell_me_more_in_fb_message: (fb_message) ->
    fb_message.text = fb_message.text.replace @tell_me_more_regex, ''
    fb_message

  user_type_to_intent:
    'landlord': 'SET_LANDLORD_CONTEXT_INTENT'
    'private': 'SET_PRIVATE_CONTEXT_INTENT'
    'social-housing': 'SET_SOCIAL-HOUSING_CONTEXT_INTENT'
    'boardinghouse': 'SET_BOARDINGHOUSE_CONTEXT_INTENT'

  Js: (object) -> JSON.stringify object, null, 2

  emit_error: (e) ->
    bus.emit "error #{e}", e.stack
    throw new Error e