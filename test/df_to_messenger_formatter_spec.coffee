{
  msec_delay
  text_reply
  text_processor
  format
  quick_replies_reply_df_native
  quick_replies_reply_handrolled
} = require '../FBMessenger/df_to_messenger_formatter'


chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


describe 'format', ->
  it 'should give just one message if a dialogflow response has the [FU] after [more]', ->
    fake_df_response = require './df_response_flatmate_rights.json'
    expect format fake_df_response.result.fulfillment.messages
      .to.have.length(1)

  it 'should split a two-line df response into two messages', ->
    fake_df_response = require './df_response_being_taken_to_tt.json'
    expect format fake_df_response.result.fulfillment.messages
      .to.have.length(2)


describe 'text_reply', ->
  it 'should, given a simple line of text without special tags, return that text', ->
    line = 'Tenancy Services has good information on how to write an insulation statement'
    expect text_reply line
      .equal line

  it 'should, given a too-long line of text, return that text with the overflow as the payload of a postback button', ->
    line = 'Tenancy Services has good information on how to write an insulation statement. Here\'s a bunch more text to flesh out the line until its longer than the 600 chars that we\'re cutting on. Here\'s a bunch more text to flesh out the line until its longer than the 600 chars that we\'re cutting on. Here\'s a bunch more text to flesh out the line until its longer than the 600 chars that we\'re cutting on. Here\'s a bunch more text to flesh out the line until its longer than the 600 chars that we\'re cutting on. Here\'s a bunch more text to flesh out the line until its longer than the 600 chars that we\'re cutting on. Here\'s a bunch more text to flesh out the line until its longer than the 600 chars that we\'re cutting on. Here\'s a bunch more text to flesh out the line until its longer than the 600 chars that we\'re cutting on. Here\'s a bunch more text to flesh out the line until its longer than the 600 chars that we\'re cutting on.'
    expect text_reply line
      .to.containSubset
        attachment:
          type: 'template'
          payload:
            template_type: 'button'
            text: (text) -> text.length < 600
            buttons: [
              type: 'postback'
              title: 'Tell me more…'
              payload: (payload) -> payload.match /^TELL_ME_MORE:/
            ]


describe 'text_processor', ->
  it 'should preseve newlines in Tell me more payload', ->
    formatted = text_processor speech: 'Line 1\n[more]\nLine 2\nLine 3\n[more]\nLine 4'
    expect formatted[0].attachment.payload.buttons[0].payload
      .to.equal 'TELL_ME_MORE:Line 2\nLine 3\n[more]\nLine 4'


  it 'should, given a df_message with a source, omit that part', ->
    fake_df_message =
      speech: 'If the boarding house has room for 6 or more tenants.
[Sources: https://www.tenancy.govt.nz/starting-a-tenancy/types-of-tenancies/boarding-houses/; http://communitylaw.org.nz/community-law-manual/chapter-14-tenancy-and-housing/boardinghouses-renting-a-room-chapter-14/]'
    expect (text_processor fake_df_message)[0]
      .to.equal 'If the boarding house has room for 6 or more tenants.'

  it 'should, given a df_message with a follow-up tag, return an appropriately formatted message', ->
    fake_df_message =
      speech: '[FU: Want to know about your rights as a boarding house tenant?: What are my rights as a boarding house tenant?]'
    expect text_processor fake_df_message
      .to.containSubset [
        text: 'Want to know about your rights as a boarding house tenant?'
        quick_replies: [
          content_type: 'text'
          payload: 'FOLLOW_UP:What are my rights as a boarding house tenant?'
        ]
      ]

  it 'should handle df_messages with multiple button tags, both formats', ->
    fake_df_message =
      speech: 'Citizen AI is developing Rentbot. We’re a charitable company owned by Community Law Wellington & Hutt Valley. Our mission is to research, develop and promote artificial intelligence systems for public benefit.
[Citizen AI http://citizenai.nz; Google http://google.com]
[Community Law http://communitylaw.org.nz/]'
    expect text_processor fake_df_message
      .to.containSubset [
        attachment:
          type: 'template'
          payload:
            template_type: 'button'
            text: 'Citizen AI is developing Rentbot. We’re a charitable company owned by Community Law Wellington & Hutt Valley. Our mission is to research, develop and promote artificial intelligence systems for public benefit.  '
            buttons: [
              type: 'web_url'
              url: 'http://citizenai.nz'
              title: '🔗 Citizen AI'
            ,
              type: 'web_url'
              url: 'http://google.com'
              title: '🔗 Google'
            ,
              type: 'web_url'
              url: 'http://communitylaw.org.nz/'
              title: '🔗 Community Law'
            ]
      ]

  it 'should handle phone numbers', ->
    fake_df_message =
      speech: 'Call the police
[OHRP 09 375 8623]
[Hell Pizza 0800 666 111]
[Police 111]'
    expect text_processor fake_df_message
      .to.containSubset [
        attachment:
          type: 'template'
          payload:
            template_type: 'button'
            text: 'Call the police   '
            buttons: [
              type: 'phone_number'
              title: '📞 OHRP'
              payload: '09 375 8623'
            ,
              type: 'phone_number'
              title: '📞 Hell Pizza'
              payload: '0800 666 111'
            ,
              type: 'phone_number'
              title: '📞 Police'
              payload: '111'
            ]
      ]

  it 'should use a pin emoji for google maps links', ->
    fake_df_message = speech: "Hi [CABs near you https://www.google.com/maps/search/citizen's+advice+near+me/]"
    result = text_processor fake_df_message
    expect result[0].attachment.payload.buttons[0]
      .to.eql
        type: 'web_url'
        title: '📍 CABs near you'
        url: "https://www.google.com/maps/search/citizen's+advice+near+me/"



  it 'should return the same result whether or not there are newlines before tags', ->
    fake_df_message1 = speech: 'Call the police [Police 111]'
    fake_df_message2 = speech: "Call the police\n[Police 111]"
    subset = [
      attachment:
        type: 'template'
        payload:
          template_type: 'button'
          text: 'Call the police '
          buttons: [
            type: 'phone_number'
            title: '📞 Police'
            payload: '111'
          ]
    ]
    expect text_processor fake_df_message1
      .to.containSubset subset
    expect text_processor fake_df_message2
      .to.containSubset subset


describe 'msec_delay', ->
  it 'should return 2000 for short messages', ->
    message = 'A short message'
    expect msec_delay message
      .equal 2000

  it 'should return 40x the number of characters in the message for simple messages', ->
    message = 'A longer simple message. Some more text to pad it out a bit'
    expect msec_delay message
      .equal message.length * 40

  it 'should return 40x the number of characters in the message for structured messages', ->
    message = attachment: payload: text: 'A longer structured message. Some more text to pad it out a bit'
    expect msec_delay message
      .equal message.attachment.payload.text.length * 40

  it 'should return 3000 for messages with quick replies', ->
    message =
      text: "Here is a quick reply!"
      quick_replies: [
        content_type: "text"
        title: "Search"
        payload: "<POSTBACK_PAYLOAD>"
        image_url: "http://example.com/img/red.png"
      ,
        content_type: "location"
      ]
    expect msec_delay message
      .equal 3000

  it 'should return 3000 for a message with a link', ->
    message =
      attachment:
        type: "template"
        payload:
          type: "web_url"
          url: "http://google.com"
          title: "Google"
    expect msec_delay message
      .equal 3000


describe 'quick_replies_reply_handrolled', ->
  it 'should work, given a correctly formatted QR tag contents', ->
    qr_tag_content = 'Some title; Yeah: Tenancy agreement definition; Nah: Subletting'
    output = quick_replies_reply_handrolled qr_tag_content
    expect output.quick_replies[1].title
      .to.equal('Nah')
    expect output.quick_replies[1].payload
      .to.equal('FOLLOW_UP: Subletting')
      

describe 'quick_replies_reply_df_native', ->
  it 'should work, given a properly formatted Dialogflow-style quick replies message', ->
    fake_df_message = require './df_response_message_qr.json'
    output = quick_replies_reply_df_native fake_df_message
    expect output.quick_replies[2].title
      .to.equal('Maybe')
    expect output.quick_replies[2].payload
      .to.equal('Maybe')
