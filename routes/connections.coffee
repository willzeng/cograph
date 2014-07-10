url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

# CREATE
exports.create = (data, callback, socket) ->
  console.log "create_connection Query Requested"
  newConnection = data
  graphDb.getNodeById newConnection.source, (err, source) ->
    graphDb.getNodeById newConnection.target, (err, target) ->
      source.createRelationshipTo target, 'connection', newConnection, (err, conn) ->
        newConnection._id = conn.id
        conn.data._id = conn.id
        conn.save () -> console.log "saved connection with id", conn.id
        socket.emit 'connections:create', newConnection
        socket.broadcast.to(newConnection._docId).emit 'connections:create', newConnection
        callback null, newConnection

# READ
exports.read = (data, callback, socket) ->
  id = data._id
  graphDb.getRelationshipById id, (err, conn) ->
    socket.emit 'connection:read', conn
    callback null, conn

exports.readCollection = (data, callback, socket) ->
  console.log "readCollection of connections in document #{data._docId}"
  docLabel = "_doc_#{data._docId || 0}"
  cypherQuery = "match (n:#{docLabel}), (n)-[r]->() return r;"
  graphDb.query cypherQuery, {}, (err, results) ->
    connections = (utils.parseCypherResult(connection, 'r') for connection in results)
    socket.emit 'connections:read', connections
    callback null, connections

# UPDATE
exports.update = (data, callback, socket) ->
  id = data._id
  newData = data
  graphDb.getRelationshipById id, (err, conn) ->
    conn.data = newData
    conn.save (err, savedConn) ->
      parsed = savedConn._data.data
      socket.emit 'connection:update', parsed
      socket.broadcast.to(parsed._docId).emit 'connections:update', parsed
      callback null, parsed

# DELETE
exports.destroy = (data, callback, socket) ->
  console.log "delete_connection Query Requested"
  id = data._id
  graphDb.getRelationshipById id, (err, conn) ->
    conn.delete () ->
      parsed = conn._data.data
      socket.emit 'connections:delete', true
      socket.broadcast.to(parsed._docId).emit 'connections:delete', parsed
      callback null, parsed
