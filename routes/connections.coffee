url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

# CREATE
exports.create = (req, resp) ->
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
exports.read = (req, resp) ->
  id = req.params.id
  graphDb.getRelationshipById id, (err, conn) ->
    resp.send conn

exports.getAll = (req, resp) ->
  console.log "get_all_connections Query Requested"
  docLabel = "_doc_id_#{req.params.docId || 0}"
  cypherQuery = "match (n:#{docLabel}), (n)-[r]->() return r;"
  graphDb.query cypherQuery, {}, (err, results) ->
    connections = (utils.parseCypherResult(connection, 'r') for connection in results)
    resp.send connections

# UPDATE
exports.update = (req, resp) ->
  id = req.params.id
  newData = req.body
  graphDb.getRelationshipById id, (err, conn) ->
    conn.data = newData
    conn.save (err, conn) ->
      console.log 'Conn updated in database with id:', conn._id
      resp.send conn

# DELETE
exports.destroy = (req, resp) ->
  console.log "delete_connection Query Requested"
  id = req.params.id
  graphDb.getRelationshipById id, (err, conn) ->
    conn.delete () -> true
