{
  msec_delay
  text_reply
  text_processor
  format
  quick_replies_reply_df_native
  quick_replies_reply_handrolled
} = require '../FBMessenger/df_to_messenger_formatter'
{cl, Js} = require '../helpers'

chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


describe 'format', ->
  it 'should handle messages with an image', ->
    df_response = require './df_responses/image.json'
    expect format df_response.queryResult.fulfillmentMessages
      .to.containSubset [
        attachment:
          type: 'image'
          payload: url: 'https://i.imgur.com/eDeFrY9.jpg'
        ]

  it 'should handle messages with a correctly formatted QR tag contents', ->
    df_response = require './df_responses/qr_native_format.json'
    output = format df_response.queryResult.fulfillmentMessages
    expect output[0].quick_replies[1].title
      .to.equal 'No'
    expect output[0].quick_replies[1].payload
      .to.equal 'No'


  it 'should handle messages including a card', ->
    df_response = require './df_responses/bond_refund_form.json'
    output = format df_response.queryResult.fulfillmentMessages
    expect output[0].attachment.payload.elements[0].buttons[0]
      .to.containSubset
        type: 'web_url'
        url: 'https://www.tenancy.govt.nz/assets/Forms-templates/bond-refund-form.pdf'
        title: 'Download the pdf'


  it 'should handle a message with both a button and follow-up', ->
    df_response = require './df_responses/insulation_responsibility.json'
    formatted = format df_response.queryResult.fulfillmentMessages
    expect formatted[1]
      .to.containSubset
        attachment:
          payload:
            buttons: {}


  it 'should handle Dialogflow native quick-reply messages', ->
    df_response = require './df_responses/get_started.json'
    formatted = format df_response.queryResult.fulfillmentMessages
    expect formatted[1]
      .to.containSubset
        quick_replies: [
          content_type: 'text'
          title: 'Renting'
          payload: 'Renting'
        ]

  it 'should properly format this complicated message', ->
    df_response = require './df_responses/complicated_message.json'
    expect format df_response.queryResult.fulfillmentMessages
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
    df_response = require './df_responses/fu_after_more.json'
    expect format df_response.queryResult.fulfillmentMessages
      .to.have.length(1)

  it 'should give two messages if a dialogflow response has the [FU] before [more]', ->
    df_response = require './df_responses/fu_before_more.json'
    expect format df_response.queryResult.fulfillmentMessages
      .to.have.length(2)

  it 'should split a three-line df response into two messages', ->
    df_response = require './df_responses/bond_lodging_correct_process.json'
    expect format df_response.queryResult.fulfillmentMessages
      .to.have.length(2)

  it 'should use a pin emoji for google maps links', ->
    df_response = require './df_responses/citizens_advice_bureau_location.json'
    output = format df_response.queryResult.fulfillmentMessages
    expect output[0].attachment.payload.buttons[0]
      .to.eql
        type: 'web_url'
        title: '📍 Find a CAB'
        url: "https://www.google.com/maps/search/citizen's+advice+near+me/"

  it 'should use a book emoji for Community Law Manual links', ->
    df_response = require './df_responses/neighbours_tree_problems.json'
    output = format df_response.queryResult.fulfillmentMessages
    expect output[0].attachment.payload.buttons[0]
      .to.eql
        type: 'web_url'
        title: '📖 Community Law Manual'
        url: "http://communitylaw.org.nz/community-law-manual/chapter-25-neighbourhood-life/trees/"

  it 'should handle phone numbers & web sites', ->
    df_response = require './df_responses/tenancy_services_contacts.json'
    output = format df_response.queryResult.fulfillmentMessages
    expect output[0]
      .to.containSubset
        attachment:
          type: 'template'
          payload:
            template_type: 'button'
            text: "Here are Tenancy Services' contacts:"
            buttons: [
              type: 'web_url'
              title: '🔗 Tenancy Services'
              url: 'https://www.tenancy.govt.nz/'
            ,
              type: 'phone_number'
              title: '📞 Tenancy Services'
              payload: '0800 836 262'
            ]



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
    processed = text_processor text: text: ["""
If you need to build a fence for your pet.
[FU: Want to know more?: Fixture definition]
[Source: https://www.aucklandcouncil.govt.nz/; s42(1) RTA]
    """]
    expect processed
      .to.not.containSubset ['']

  it 'should, given a df_message with QR tags, handle it properly', ->
    processed = text_processor text: text: ['Something [QR: Title; Option 1: opt1]']
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

  it 'should, given a df_message with a source, omit that part', ->
    fake_df_message = text: text:
      ['If the boarding house.\n[Sources: https://www.tenancy.govt.nz; http://communitylaw.org.nz]']
    expect (text_processor fake_df_message)[0]
      .to.equal 'If the boarding house.'

  it 'should, given a df_message with a follow-up tag, return an appropriately formatted message', ->
    fake_df_message = text: text:
      ['[FU: Want to know about your rights as a boarding house tenant?: What are my rights as a boarding house tenant?]']
    expect text_processor fake_df_message
      .to.containSubset [
        text: 'Want to know about your rights as a boarding house tenant?'
        quick_replies: [
          content_type: 'text'
          payload: 'FOLLOW_UP:What are my rights as a boarding house tenant?'
        ]
      ]

  it 'should handle df_messages with multiple button tags, both formats', ->
    fake_df_message = text: text: ["""
Citizen AI is developing Rentbot.
[Citizen AI http://citizenai.nz; Google http://google.com]
[Community Law http://communitylaw.org.nz/]
"""]
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

  it 'should return the same result whether or not there are newlines before tags', ->
    fake_df_message1 = text: text: ['Call the police [Police 111]']
    fake_df_message2 = text: text: ["Call the police\n[Police 111]"]
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
