# TODO: https://stackoverflow.com/questions/24547357/setting-up-singleton-connection-with-node-js-and-mongo

MongoClient = require('mongodb').MongoClient


DbConnection = () ->
  db = null
  instance = 0

  DbConnect = () ->
    try
      _db = await MongoClient.connect 'mongodb:' + process.env.mongoatlas_db_string
      return _db
    catch e
      return e

   Get = () ->
     try
       instance++
       console.log "DbConnection called #{instance} times"

       if db isnt null
         console.log 'db connection is already alive'
         db
       else
         console.log 'getting new db connection'
         return await DbConnect()
      catch e
        return e

    Get: Get


module.exports = DbConnection()
