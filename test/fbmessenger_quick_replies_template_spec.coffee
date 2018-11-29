quick_replies_template = require '../FBMessenger/templates/quick_replies'

chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


describe 'quick_replies_template', ->
  it 'should work with handrolled & options', ->
    qr_options = [
      title: 'Yes'
    ,
      title: 'No'
      payload: 'Not at all'
    ]
    output = quick_replies_template
      title: 'Ready?'
      replies: qr_options
    expect output.text
      .to.equal('Ready?')
    expect output.quick_replies[0].payload
      .to.equal('Yes')

    # expect (quick_replies_template elements).attachment.payload.elements[1].subtitle
    #   .to.equal("What to do if you can't find your tenancy agreement")
    # expect (list_template elements).attachment.payload.elements[0].subtitle
    #   .to.not.exist
