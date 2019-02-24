chai = require 'chai'
chai.use require 'chai-subset'
{expect} = chai


db_connection = require '../logger/db'


describe 'db', ->
  it 'should connect to the databases', ->
    conn = await db_connection.Get()
    expect conn.db()
      .to.not.be.null

  it 'should find some records', ->
    conn = await db_connection.Get()
    db = conn.db()
    # collection = await db.collection('test')
    # records = await collection.find({})
    # console.log records.toArray()
    db.listCollections().toArray (err, collInfos) ->
      console.log collInfos
