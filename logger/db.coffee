MongoClient = require('mongodb').MongoClient
bus = require '../event_bus'
{Js} = require '../helpers'

url = "mongodb://localhost"
dbName = 'rentbot-local'
client = new MongoClient url


connect = () ->
  try
    conn = await client.connect()
    conn.db dbName
  catch e
    bus.emit 'error:', e, 'Logging is disabled'
    null


db = connect()
if db
  db.then (conn) ->
    bus.emit "connected to database: #{conn.s.databaseName}"

module.exports =
  db: db

  users_collection: () ->
    conn = await db
    conn.collection 'users'

  events_collection: () ->
    conn = await db
    conn.collection 'events'
