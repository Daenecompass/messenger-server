MongoClient = require('mongodb').MongoClient


url = "mongodb://localhost"
dbName = 'rentbot-local'
client = new MongoClient url


connect = () ->
  conn = await client.connect()
  conn.db dbName


db = connect()


module.exports =
  db: db

  users_collection: () ->
    conn = await db
    conn.collection 'users'

  events_collection: () ->
    conn = await db
    conn.collection 'events'
