module.exports =
  tell_me_more_regex: /^tell_me_more: ?/i
  follow_up_regex: /^follow_up: ?/i

  remove_tell_me_more_in_fb_message: (fb_message) ->
    console.log fb_message
    fb_message.text = fb_message.text.replace @tell_me_more_regex, ''
    fb_message
