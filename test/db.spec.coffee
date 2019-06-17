chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai

mongoose = require 'mongoose'

{User, Event} = require '../logger/db'
{Js} = require '../helpers'

ObjectId = mongoose.Schema.Types.ObjectId


describe 'db', ->
  it 's models should populate', ->
    User
      .find()
      .populate 'events'
      .then (x) ->
        expect x[0].events.length
          .to.be.at.least 4
