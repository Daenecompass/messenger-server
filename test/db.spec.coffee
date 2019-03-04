chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


{users_collection, events_collection} = require('../logger/db')


describe 'db', ->
  # it 'should connect to the database', ->
  #   db_connection (conn) ->
  #     expect conn.db()
  #       .to.not.be.null

  it 'should find some records', ->
    users = await users_collection()
    all_users = await users.find({}).toArray()
    expect all_users.length
      .to.be.at.least 1


  it 'should let me insert a record', ->
    events = await events_collection()
    events.insertOne
      timestamp: Date.now()
      note: 'Wallaby test run'
