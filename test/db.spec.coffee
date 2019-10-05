chai = require 'chai'
chai.use require 'chai-subset'
{ expect } = chai

mongoose = require 'mongoose'

{ User, Event } = require '../db'
{ Js } = require '../helpers'

# ObjectId = mongoose.Schema.Types.ObjectId


describe 'db', ->
  # it 's models should populate', ->
  #   User
  #     .find()
  #     .populate 'events'
  #     .then (x) ->
  #       expect x[0].events.length
  #         .to.be.at.least 4

  it 'something', ->
    df_session = 123
    user = await User.findOne _id: '1807838475942004'
    if user and user.last_session_id is df_session
      console.log 'same session'
    else if user and user.last_session_id isnt df_session
      user.last_session_id = df_session
      user.save()
    else
      new_user = new User 
      new_user._id = '1807838475942004'
      new_user.last_session_id = df_session
      new_user.save()