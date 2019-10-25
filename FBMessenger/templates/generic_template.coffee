# https://developers.facebook.com/docs/messenger-platform/send-messages/template/generic/

# TODO: Default action (first button)
# TODO: collect up all cards into a carousel


module.exports = ({ title, subtitle, buttons, image_url }) ->
  attachment:
    type: 'template'
    payload:
      template_type: 'generic'
      elements: [
        if buttons.length isnt 0
          title: title
          image_url: image_url
          subtitle: subtitle
          buttons: buttons.map (button) ->
            type: 'web_url'
            url: button.postback
            title: button.text
        else
          title: title
          image_url: image_url
          subtitle: subtitle
      ]
