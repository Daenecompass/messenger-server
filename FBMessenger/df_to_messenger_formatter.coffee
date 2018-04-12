_ = require 'lodash'
flatmap = require 'flatmap'
helpers = require '../helpers'

image_reply = (df_message) ->
  attachment:
    type: 'image'
    payload:
      url: df_message.imageUrl

quick_replies_reply = (df_message) ->
  text: df_message.title
  quick_replies:
    _.map df_message.replies, (qr) ->
      content_type: 'text'
      title: qr
      payload: qr

postback_button = (title, payload) ->
  type: 'postback'
  title: title
  payload: payload

button_template_attachment = (title, buttons) ->
  attachment:
    type: 'template'
    payload:
      template_type: 'button'
      text: title
      buttons: buttons

follow_up_button = (label, payload) ->
  button_template_attachment label, [postback_button('Okay', 'FOLLOW_UP:' + payload)]


filter_dialogflow_duplicates = (df_messages) ->
  _.uniqWith(df_messages, (a, b) -> a.speech?) # I don't understand why this works

remove_newlines_around_more = (text) ->
  text.replace /(\n ?)?(\[more\])( ?\n)?/ig, '$2'

remove_newlines_before_buttons = (text) ->
  text.replace /(\n)(\[(.+(http|0800).+)\])/ig, '$2'

# thanks http://stackoverflow.com/a/5454303
truncate_to_word = (string, maxLength) ->
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

has_more = (text) -> text.match(/\[more\]/i)?
text_before_more = (text) -> text.match(/(.*)\[more\]/i)?[1]
text_after_more = (text) -> text.match(/\[more\](.*)/i)?[1]

buttons_prep = (button_text) ->
  button_text
    .split /; ?/
    .map (b) ->
      messenger_url = b.match /(.+) (https?:\/\/m\.me\/.+)/i
      page_url = b.match /(.+) (https?:\/\/.+)/i
      phone_number = b.match /(.+) (0800.+)/
      if messenger_url
        type: 'web_url'
        url: messenger_url[2]
        title: '💬 ' + messenger_url[1]
      else if page_url
        type: 'web_url'
        url: page_url[2]
        title: '🔗 ' + page_url[1]
      else if phone_number
        type: 'phone_number'
        title: '📞 ' + phone_number[1]
        payload: phone_number[2]
      else console.error 'Error: Badly formatted button instruction in Dialogflow'

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
  button_tag = split_text.reply_text.match helpers.phone_web_tag_regex
  if not button_tag and not split_text.overflow
    df_speech
  else
    buttons = []
    if button_tag then buttons = buttons_prep button_tag[1]
    if split_text.overflow
      buttons.push postback_button 'Tell me more', 'TELL_ME_MORE:' + split_text.overflow
    button_template_attachment split_text.reply_text.replace(helpers.phone_web_tag_regex, ''), buttons



text_processor = (df_message) ->
  cleaned_speech = remove_newlines_around_more remove_newlines_before_buttons df_message.speech
  lines = split_on_newlines_before_more cleaned_speech
  output = []
  lines.map (line) ->
    follow_up_tag = line.match helpers.follow_up_tag_regex
    if follow_up_tag
      cleaned_line = line.replace(helpers.follow_up_tag_regex, '').trim()
      output.push text_reply cleaned_line
      output.push follow_up_button follow_up_tag[1], follow_up_tag[2]
    else
      output.push text_reply line
  output

msec_delay = (message) ->
  delay =
    if typeof message is 'string'
      message.length * 40
    else if message.attachment?.payload?.text?
      message.attachment.payload.text.length * 40
    else if message.attachment?.payload?.url?
      3000
    else if message.quick_replies?
      3000
  if delay < 2000 then delay = 2000
  delay

df_message_type_to_func =
  0: text_processor
  2: quick_replies_reply
  3: image_reply

formatter = (df_messages) ->
  unique_df_messages = filter_dialogflow_duplicates df_messages
  flatmap unique_df_messages, (df_message) ->
    df_message_type_to_func[df_message.type] df_message

module.exports =
  formatter: formatter
  msec_delay: msec_delay
