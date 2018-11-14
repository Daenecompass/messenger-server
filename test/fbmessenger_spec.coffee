{tell_me_more} = require '../FBMessenger/index'
{format} = require '../FBMessenger/df_to_messenger_formatter'
{regex, df_message_format} = require '../helpers'


chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


describe 'tell_me_more', ->
  it 'should work', ->
    # mocking up tell_me_more, as we can't actually send while testing
    fb_message = text: 'TELL_ME_MORE:Line 2\nLine 3\n[more]\nLine 4'
    tell_me_more_content = fb_message.text.match(/^tell_me_more: ?([\s\S]*)/i)?[1]
    tell_me_more_content #
    fb_messages = format df_message_format tell_me_more_content
    console.log fb_messages
