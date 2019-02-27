chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


{db, users_collection} = require('../logger/db')


describe 'db', ->
  # it 'should connect to the database', ->
  #   db_connection (conn) ->
  #     expect conn.db()
  #       .to.not.be.null

  it 'should find some records', ->
    users = await users_collection()
    console.log await users.find({})

    # console.log await coll.find({}).toArray()

    # collection = await db.collection 'users'
    # users = await collection.find({}).toArray()
    # console.log users
    # expect users.length
    #   .to.be.at.least(1)

  # it 'should let me insert a record', ->
  #   conn = await db_connection()
  #   db = conn.db()
  #   collection = await db.collection 'dbtest'
  #   collection.insertOne
  #     timestamp: Date.now()
  #     note: 'Wallaby test run'
