express = require 'express'
connections = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

connections.param 'id', (req, res, next, id) ->
  req.id = id
  next()

# CREATE
connections.post '/', (req, resp) ->
  console.log "create_connection Query Requested"
  newConnection = req.body
  graphDb.getNodeById newConnection.source, (err, source) ->
    graphDb.getNodeById newConnection.target, (err, target) ->
      source.createRelationshipTo target, 'connection', newConnection, (err, conn) ->
        newConnection._id = conn.id
        conn.data._id = conn.id
        conn.save (err, conn) ->
          console.log 'Updated id of connection'
        resp.send newConnection


# READ
connections.get '/:id', (req, resp) ->
  id = req.params.id
  graphDb.getRelationshipById id, (err, conn) ->
    resp.send conn

connections.get '/', (req, resp) ->
  console.log "get_all_connections Query Requested"
  cypherQuery = "start r=rel(*) return r;"
  graphDb.query cypherQuery, {}, (err, results) ->
    connections = (utils.parseCypherResult(connection, 'r') for connection in results)
    resp.send connections

# UPDATE
connections.put '/:id', (req, resp) ->
  id = req.params.id
  newData = req.body
  graphDb.getRelationshipById id, (err, conn) ->
    conn.data = newData
    conn.save (err, conn) ->
      console.log 'Conn updated in database with id:', conn._id
      resp.send conn

# DELETE
connections.delete '/:id', (req, resp) ->
  id = req.params.id
  console.log "delete_connection Query Requested"
  graphDb.getRelationshipById id, (err, conn) ->
    conn.delete () -> true

module.exports = connections
