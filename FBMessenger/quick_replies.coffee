# https://developers.facebook.com/docs/messenger-platform/send-messages/quick-replies/



module.exports = ({title, replies}) ->
  text: df_message.title
  quick_replies:
    _.map df_message.replies, (reply) ->
      content_type: 'text'
      title: reply
      payload: reply
