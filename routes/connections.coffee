express = require 'express'
connections = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require 'utils'

connections.param 'id', /^\d+$/

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
connections.get '/', (req, resp) ->
  console.log "get_all_connections Query Requested"
  cypherQuery = "start n=rel(*) return n;"
  graphDb.query cypherQuery, {}, (err, results) ->
    connections = (utils.parseCypherNode(connection) for connection in results)
    resp.send connections

# UPDATE

# DELETE
connections.post '/:id', (req, resp) ->
  console.log "delete_node Query Requested"
  deleteNode = req.body
  cypherQuery = "start n=node(#{deleteNode._id}) delete n;"
  graphDb.query cypherQuery, {}, (err, results) ->
    resp.send true

modeule.exports = connections
