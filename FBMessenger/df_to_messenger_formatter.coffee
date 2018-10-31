# knows everything rentbot needs to know about the FB Messenger api format

_ = require 'lodash'
flatmap = require 'flatmap'

bus = require '../event_bus'
{regex} = require '../helpers'


image_reply = (df_message) ->
  attachment:
    type: 'image'
    payload:
      url: df_message.imageUrl


quick_replies_reply = (df_message) ->
  text: df_message.title
  quick_replies:
    _.map df_message.replies, (reply) ->
      content_type: 'text'
      title: reply
      payload: reply


# TODO: Default action (first button)
# TODO: collect up all cards into a carousel
card_reply = (df_message) ->
  attachment:
    type: 'template'
    payload:
      template_type: 'generic'
      elements: [
        if df_message.buttons.length isnt 0
          title: df_message.title
          image_url: df_message.imageUrl
          subtitle: df_message.subtitle
          buttons: _.map df_message.buttons, (button) ->
            type: 'web_url'
            url: button.postback
            title: button.text
        else
          title: df_message.title
          image_url: df_message.imageUrl
          subtitle: df_message.subtitle
      ]


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
  text: label
  quick_replies: [
    content_type: 'text'
    title: 'Yes'
    payload: 'FOLLOW_UP:' + payload
  ,
    content_type: 'text'
    title: 'No'
    payload: 'FOLLOW_UP: FU No'
  ]


filter_dialogflow_duplicates = (df_messages) ->
  _.uniqWith(df_messages, (a, b) -> a.speech?) # I don't understand why this works


remove_newlines_around_more = (text) -> text.replace /(\n ?)?(\[more\])( ?\n)?/ig, '$2'
remove_newlines_before_buttons = (text) -> text.replace regex.newline_button_tag, '$2'
remove_sources_tags = (df_speech) -> df_speech.replace /(\[Sources?: .+?\])/ig, ''


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


has_more = (text) -> text.match(/\[more\]/i)?
text_before_more = (text) -> text.match(/(.*)\[more\]/i)?[1]
text_after_more = (text) -> text.match(/\[more\](.*)/i)?[1]


buttons_prep = (button_tags) ->
  flatmap button_tags, (button_tag) ->
    button_tag = button_tag.replace /\[|\]/g, ''
    flatmap (button_tag.split /; ?/), (button_text) ->
      map_url = button_text.match regex.map_url
      pdf_url = button_text.match regex.pdf_url
      messenger_url = button_text.match regex.messenger_url
      page_url = button_text.match regex.url
      phone_number = button_text.match regex.phone
      if map_url
        type: 'web_url'
        url: map_url[2]
        title: "📍 #{map_url[1]}"
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
      buttons.push postback_button 'Tell me more…', 'TELL_ME_MORE:' + split_text.overflow
    button_template_attachment split_text.reply_text.replace(regex.button_tag, ''), buttons


text_processor = (df_message) ->
  cleaned_speech = remove_newlines_around_more \
    remove_newlines_before_buttons \
    remove_sources_tags \
    df_message.speech
  lines = split_on_newlines_before_more cleaned_speech
  output = []
  lines.map (line) ->
    line = line.trim()
    follow_up_tag = line.match regex.follow_up_tag
    if follow_up_tag
      cleaned_line = line.replace(regex.follow_up_tag, '').trim()
      output.push text_reply cleaned_line
      output.push follow_up_button follow_up_tag[1], follow_up_tag[2]
    else
      output.push text_reply line
  output


msec_delay = (message) ->
  delay =
    if typeof message is 'string'
      message.length * 40                        # ms per char ~ wpm
    else if message.attachment?.payload?.text?
      message.attachment.payload.text.length * 40
    else
      3000
  if delay < 2000 then delay = 2000
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
  df_message_type_to_func =
    0: text_processor
    1: card_reply
    2: quick_replies_reply
    3: image_reply

  unique_df_messages = filter_dialogflow_duplicates df_messages
  flatmap unique_df_messages, (df_message) ->
    if df_message.type in [0..3]
      df_message_type_to_func[df_message.type] df_message
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
  remove_newlines_before_buttons
}
