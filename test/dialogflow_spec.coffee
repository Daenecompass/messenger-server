{response_wellformed} = require '../Dialogflow/index'

chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


describe 'response_wellformed', ->
  it 'should be false if [more] wrongly used', ->
    expect response_wellformed result: fulfillment: messages: [speech: 'Can you hear me? [more: something]']
      .to.be.false

  it 'should be false if FU syntax missing colons', ->
    expect response_wellformed result: fulfillment: messages: [speech: 'Can you hear me? [FU: Want to know whats what? Heres whats what]']
      .to.be.false

  it 'should be true if FU syntax correct', ->
    expect response_wellformed result: fulfillment: messages: [speech: 'Can you hear me? [FU: Want to know whats what?: Heres whats what]']
      .to.be.true

  it 'should be true if FU syntax absent', ->
    expect response_wellformed result: fulfillment: messages: [speech: 'Can you hear me?']
      .to.be.true

  it 'should be true if smiley used', ->
    expect response_wellformed result: fulfillment: messages: [speech: 'Hi :)']
      .to.be.true

  it 'should be false if unbalanced parentheses', ->
    expect response_wellformed result: fulfillment: messages: [speech: 'Hi )']
      .to.be.false
