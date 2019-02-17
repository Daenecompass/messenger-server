# knows everything rentbot needs to know about the FB Messenger api format

_ = require 'lodash'
flatmap = require 'flatmap'

bus = require '../event_bus'
{cl, regex, remove_empties} = require '../helpers'

# pure FB templates (knowing nothing about DF's or Rentbot's APIs)
image_reply_template = require './templates/image_reply'
quick_replies_template = require './templates/quick_replies'
generic_template = require './templates/generic_template'
button_template_attachment = require './templates/button_template_attachment'
postback_button = require './templates/postback_button'

# less pure templates
follow_up_button = require './templates/follow_up_button'


# these functions translate between dialoglow-style message types, and the FB Messenger API

image_reply = (df_message) ->
  image_reply_template df_message.imageUrl


card_reply = (df_message) ->
  generic_template
    title: df_message.title
    subtitle: df_message.subtitle
    image_url: df_message.imageUrl
    buttons: df_message.buttons


quick_replies_reply_df_native = (df_message) ->
  quick_replies_template
    title: df_message.title
    replies: df_message.replies.map (reply) ->
      title: reply
      payload: reply


quick_replies_reply_handrolled = (qr_tag_contents) ->
  [title, ...options] = qr_tag_contents.split /; ?/
  quick_replies_template
    title: title
    replies: options.map (option) ->
      [title, payload] = option.split /: ?/
      title: title
      payload: "FOLLOW_UP: #{payload}"

# --- #


filter_dialogflow_duplicates = (df_messages) ->
  _.uniqWith(df_messages, (a, b) -> a.speech?) # I don't understand why this works


remove_sources_tags = (text) -> text.replace /(\[Sources?.+\])/ig, ''


truncate_to_word = (string, maxLength) ->   # thanks http://stackoverflow.com/a/5454303
  if string.length > maxLength
    truncatedString = string.substring 0, maxLength
    truncatedString
      .substring 0, Math.min truncatedString.length, truncatedString.lastIndexOf ' '
      .concat ' …'
  else
    string


split_on_newlines_before_more = (text) ->
  more_position = text.search /\[more\]/i
  if more_position isnt -1
    text_before_more = text.substring 0, more_position
    lines_before_more = text_before_more.split /\n/
    text_after_more = text.substring more_position
    lines_before_more[lines_before_more.length - 1] += text_after_more
    lines_before_more
  else
    text.split /\n/


buttons_prep = (button_tags) ->
  flatmap button_tags, (button_tag) ->
    button_tag = button_tag.replace /\[|\]/g, ''
    flatmap (button_tag.split /; ?/), (button_text) ->
      map_url = button_text.match regex.map_url
      clm_url = button_text.match regex.clm_url
      pdf_url = button_text.match regex.pdf_url
      messenger_url = button_text.match regex.messenger_url
      page_url = button_text.match regex.url
      phone_number = button_text.match regex.phone
      if map_url
        type: 'web_url'
        url: map_url[2]
        title: "📍 #{map_url[1]}"
      else if clm_url
        type: 'web_url'
        url: clm_url[2]
        title: "📖 #{clm_url[1]}"
      else if pdf_url
        type: 'web_url'
        url: pdf_url[2]
        title: "📄 #{pdf_url[1]}"
      else if messenger_url
        type: 'web_url'
        url: messenger_url[2]
        title: "💬 #{messenger_url[1]}"
      else if page_url
        type: 'web_url'
        url: page_url[2]
        title: "🔗 #{page_url[1]}"
      else if phone_number
        type: 'phone_number'
        title: "📞 #{phone_number[1]}"
        payload: phone_number[2]
      else
        bus.emit "Error: Badly formatted button instruction in Dialogflow: #{button_text}"


split_text_by_more_and_length = (text) ->
  more_position = text.search /\[more\]/i
  if more_position is -1 and text.length < 600    # short message with no '[more]'
    reply_text = text
  else if more_position isnt -1                   # message with '[more]'
    reply_text = text.substring 0, more_position
    overflow = text.substring reply_text.length + 6, reply_text.length + 985
  else if text.length > 600                       # long message
    reply_text = truncate_to_word text, 600
    overflow = text.substring reply_text.length - 2, reply_text.length + 985
  reply_text: reply_text
  overflow: overflow


text_reply = (df_speech) ->
  split_text = split_text_by_more_and_length df_speech
  button_tags = split_text.reply_text.match regex.button_tag
  if not button_tags and not split_text.overflow
    df_speech
  else
    buttons = []
    if button_tags then buttons = buttons_prep button_tags
    if split_text.overflow
      buttons.push postback_button
        title: 'Tell me more…'
        payload: 'TELL_ME_MORE:' + split_text.overflow
    button_template_attachment
      title: split_text.reply_text.replace(regex.button_tag, '')
      buttons: buttons


remove_extra_whitespace = (text) ->
  text
    .replace /[\s]*\n[\s]*/g, '\n'
    .replace regex.whitespace_around_first_more, '$1'
    .replace /[\s]*(\[.*?\])/ig, '$1'


has_followup_before_more = (text) ->
  text
    .replace /(\[more\][\s\S]*)/i, ''  # strip out from first more on
    .match regex.follow_up_tag


has_qr_before_more = (text) ->
  text
    .replace /(\[more\][\s\S]*)/i, ''  # strip out from first more on
    .match regex.quick_replies_tag


follow_up_reply = (text) ->
  [, label, payload] = text.match regex.follow_up_tag
  rest_of_line = text
    .replace regex.follow_up_tag, ''
    .trim()
  [rest_of_line, follow_up_button {label, payload}]


quick_replies_reply = (text) ->
  [, qr_tag_contents] = text.match regex.quick_replies_tag
  rest_of_line = text
    .replace regex.quick_replies_tag, ''
    .trim()
  [rest_of_line, quick_replies_reply_handrolled qr_tag_contents]


text_processor = (df_message) ->
  cleaned_speech = remove_extra_whitespace remove_sources_tags df_message.speech
  lines = split_on_newlines_before_more cleaned_speech
  flatmap lines, (line) ->
    if has_followup_before_more line
      follow_up_reply line
    else if has_qr_before_more line
      quick_replies_reply line
    else
      text_reply line


msec_delay = (message) ->
  if process.env.delay_ms? then msecs = process.env.delay_ms else msecs = 40
  delay =
    if typeof message is 'string'
      message.length * msecs
    else if message.attachment?.payload?.text?
      message.attachment.payload.text.length * msecs
    else
      3000
  if delay < 1000 then delay = 1000
  delay


apply_fn_to_fb_message = (message, fn) ->
  if typeof message is 'string'
    message = fn message
  else if message.text?
    message.text = fn message.text
  else if message.attachment?.payload?.text?
    message.attachment.payload.text = fn message.attachment.payload.text
  else if message.title? # quick replies
    message.title = fn message.title
  message


apply_fn_to_fb_messages = (messages, fn) ->
  messages.map (message) ->
    apply_fn_to_fb_message message, fn


search_fb_message_text = (message, term) ->
  if typeof message is 'string'
    message.match term
  else if message.text?
    message.text.match term
  else if message.attachment?.payload?.text?
    message.attachment.payload.text.match term
  else if message.title? # quick replies
    message.title.match term


fb_messages_text_contains = (messages, term) ->
  matches = (messages.filter (message) ->
    search_fb_message_text(message, term)?)
  if matches.length is 0 then false else true


format = (df_messages) ->
  unique_df_messages = filter_dialogflow_duplicates df_messages
  flatmap unique_df_messages, (df_message) ->
    switch df_message.type
      when 0 then text_processor df_message
      when 1 then card_reply df_message
      when 2 then quick_replies_reply_handrolled df_message
      when 3 then image_reply df_message
      else
        bus.emit 'error: message from dialogflow with unknown type', "Message type: #{df_message.type}"


module.exports = {
  format
  msec_delay
  apply_fn_to_fb_messages
  fb_messages_text_contains
  # for testing
  text_reply
  text_processor
  quick_replies_reply_handrolled
  quick_replies_reply_df_native
}
