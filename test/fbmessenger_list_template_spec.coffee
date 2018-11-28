list_template = require '../FBMessenger/list_template'

chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


describe 'list_template', ->
  it 'should work', ->
    elements = [
      title: 'Tenancy agreement'
      image_url: 'https://i.imgur.com/MzCq1jy.jpg'
      payload: 'Whats a tenancy agreement'
    ,
      title: 'Missing tenancy agreement'
      subtitle: "What to do if you can't find your tenancy agreement"
      payload: 'lost tenancy agreement'
    ]
    expect (list_template elements).attachment.payload.elements[1].subtitle
      .to.equal("What to do if you can't find your tenancy agreement")
    expect (list_template elements).attachment.payload.elements[0].subtitle
      .to.not.exist
