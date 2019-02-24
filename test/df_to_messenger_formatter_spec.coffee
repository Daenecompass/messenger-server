{
  msec_delay
  text_reply
  text_processor
  format
  quick_replies_reply_df_native
  quick_replies_reply_handrolled
} = require '../FBMessenger/df_to_messenger_formatter'
{cl} = require '../helpers'

chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


describe 'format', ->
  it 'should handle a message with both a button and follow-up', ->
    fake_df_response = require './df_responses/insulation_responsibility.json'
    formatted = format fake_df_response.result.fulfillment.messages
    formatted #
    expect formatted[0]
      .to.containSubset
        attachment:
          payload:
            buttons: {}


  it 'should handle Dialogflow native quick-reply messages', ->
    fake_df_response = require './df_responses/get_started.json'
    formatted = format fake_df_response.result.fulfillment.messages
    expect formatted[1]
      .to.containSubset
        quick_replies: [
          content_type: 'text'
          title: 'Renting'
          payload: 'Renting'
        ]

  it 'should properly format this complicated message', ->
    expect format [
      type: 0
      speech: "Line 1 [FU: Follow-up: follow-up] \nLine 2\n \n[more]\nLine 3 \n Line 4 \n[more] Line 5 \n Line 6"
    ]
      .to.containSubset [
        'Line 1'
      ,
        text: 'Follow-up'
        quick_replies: [
          content_type: 'text'
          title: 'Yes'
          payload: 'FOLLOW_UP:follow-up'
        ,
          content_type: 'text'
          title: 'No'
          payload: 'FOLLOW_UP: FU No'
        ]
      ,
        attachment:
          type: 'template'
          payload:
            template_type: 'button'
            text: 'Line 2'
            buttons: [
              type: 'postback'
              title: 'Tell me more…'
              payload: 'TELL_ME_MORE:Line 3\nLine 4[more] Line 5\nLine 6'
            ]
      ]

  it 'should give just one message if a dialogflow response has the [FU] after [more]', ->
    expect format [type: 0, speech: "Line 1\n[more]\nLine 2\n[FU: Follow-up: follow-up]"]
      .to.have.length(1)

  it 'should give two messages if a dialogflow response has the [FU] before [more]', ->
    expect format [type: 0, speech: "Line 1 [FU: Follow-up: follow-up][more]\nLine 2"]
      .to.have.length(2)

  it 'should split a two-line df response into two messages', ->
    fake_df_response = require './df_responses/being_taken_to_tt.json'
    expect format fake_df_response.result.fulfillment.messages
      .to.have.length(2)


describe 'text_reply', ->
  it 'should produce a button even with run-on button tag', ->
    expect text_reply 'Some words.[Read more https://alink.com]'
      .to.containSubset attachment: payload: buttons: []

  it 'should, given a simple line of text without special tags, return that text', ->
    line = 'Tenancy Services has good information on how to write an insulation statement'
    expect text_reply line
      .to.equal line

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
  it 'should include no empty messages', ->
    processed = text_processor speech: """
If you need to build a fence for your pet.
[FU: Want to know more?: Fixture definition]
[Source: https://www.aucklandcouncil.govt.nz/; s42(1) RTA]
    """
    expect processed
      .to.not.containSubset ['']

  it 'should, given a df_message with QR tags, handle it properly', ->
    processed = text_processor speech: 'Something [QR: Title; Option 1: opt1]'
    expect processed
      .to.containSubset [
        'Something'
      ,
        text: 'Title'
        quick_replies: [
          content_type: 'text'
          title: 'Option 1'
          payload: 'FOLLOW_UP: opt1'
        ]
      ]

  # it 'should preseve newlines in Tell me more payload', ->
  #   formatted = text_processor speech: 'Line 1\n[more]\nLine 2\nLine 3\n[more]\nLine 4'
  #   expect formatted[0].attachment.payload.buttons[0].payload
  #     .to.equal 'TELL_ME_MORE:Line 2\nLine 3\n[more]\nLine 4'
  #
  #
  it 'should, given a df_message with a source, omit that part', ->
    fake_df_message = speech: 'If the boarding house.\n[Sources: https://www.tenancy.govt.nz; http://communitylaw.org.nz]'
    expect (text_processor fake_df_message)[0]
      .to.equal 'If the boarding house.'

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
    fake_df_message = speech: """
Citizen AI is developing Rentbot.
[Citizen AI http://citizenai.nz; Google http://google.com]
[Community Law http://communitylaw.org.nz/]
"""
    processed = text_processor fake_df_message
    expect processed[0].attachment.payload
      .to.containSubset
        template_type: 'button'
        text: 'Citizen AI is developing Rentbot.'
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

  it 'should handle phone numbers', ->
    fake_df_message =
      speech: 'Call the police \n [OHRP 09 375 8623] [Hell Pizza 0800 666 111]\n[Police 111]'
    expect text_processor fake_df_message
      .to.containSubset [
        attachment:
          type: 'template'
          payload:
            template_type: 'button'
            text: 'Call the police'
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

  it 'should use a book emoji for Community Law Manual links', ->
    fake_df_message = speech: "Hi [Trees http://communitylaw.org.nz/community-law-manual/chapter-25-neighbourhood-life/trees/]"
    result = text_processor fake_df_message
    expect result[0].attachment.payload.buttons[0]
      .to.eql
        type: 'web_url'
        title: '📖 Trees'
        url: "http://communitylaw.org.nz/community-law-manual/chapter-25-neighbourhood-life/trees/"


  it 'should return the same result whether or not there are newlines before tags', ->
    fake_df_message1 = speech: 'Call the police [Police 111]'
    fake_df_message2 = speech: "Call the police\n[Police 111]"
    subset = [
      attachment:
        type: 'template'
        payload:
          template_type: 'button'
          text: 'Call the police'
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
  it 'should return 1 second for short messages', ->
    message = 'A short message'
    expect msec_delay message
      .equal 1000

  it 'should return the right delay for the number of characters in the message for simple messages', ->
    message = 'A longer simple message. Some more text to pad it out a bit. And yet more text so that it is long enough.'
    if process.env.delay_ms?
      expect msec_delay message
        .equal message.length * process.env.delay_ms
    else
      expect msec_delay message
        .equal message.length * 40

  it 'should return the right delay the number of characters in the message for structured messages', ->
    message = attachment: payload: text: 'A longer structured message. Some more text to pad it out a bit. And yet more text'
    if process.env.delay_ms?
      expect msec_delay message
        .equal message.attachment.payload.text.length * process.env.delay_ms
    else
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
    fake_df_message = require './df_responses/message_qr.json'
    output = quick_replies_reply_df_native fake_df_message
    expect output.quick_replies[2].title
      .to.equal('Maybe')
    expect output.quick_replies[2].payload
      .to.equal('Maybe')
