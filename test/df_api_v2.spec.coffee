{send_context} = require '../Dialogflow/df_api_v2'

chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


describe 'send_context', ->
  it 'should send & receive the correct number of contexts', ->
    send_context
      session_id: 1807838475942004
      user_type: 'social-housing'
      fb_first_name: 'Bob'
      on_success: () ->
      on_failure: () ->
