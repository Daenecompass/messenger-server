chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


{from_fb} = require '../logger/'


describe 'from_fb', ->
  it 'should make a log entry', ->
    mongo_response = await from_fb
      fb_message:
        user: 123
        text: 'Hello there todd'
    expect mongo_response.result.ok
      .to.equal 1
