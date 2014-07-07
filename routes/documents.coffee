url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

DocumentHelper = require __dirname + '/helpers/DocumentHelper'
serverDocument = new DocumentHelper graphDb

# CREATE
exports.create = (data, callback, socket) ->
  console.log 'create document query requested'
  newDocument = data
  serverDocument.create newDocument, (savedDocument) ->
    socket.emit('document:create', savedDocument)
    # socket.broadcast.emit('documents:create', json)
    callback(null, savedDocument)

# READ
exports.read = (data, callback, socket) ->
  id = data._id
  graphDb.getNodeById id, (err, node) ->
    if err
      console.log 'Something broke!'
    else
      parsed = utils.parseNodeToClient node._data.data
      socket.emit 'document:read', parsed
      callback null, parsed

exports.readCollection = (data, callback, socket) ->
  console.log "get the document collection"
  docLabel = '_document'
  cypherQuery = "match (n:#{docLabel}) return n;"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then throw err
    nodes = (utils.parseCypherResult(node, 'n') for node in results)
    socket.emit 'documents:read', nodes
    callback null, nodes

exports.getAll = (req, resp) ->
  console.log "Get all Documents Query Requested"
  docLabel = '_document'
  cypherQuery = "match (n:#{docLabel}) return n;"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then throw err
    nodes = (utils.parseCypherResult(node, 'n') for node in results)
    resp.send nodes

# UPDATE
exports.update = (data, callback, socket) ->
  id = data._id
  props = data
  serverDocument.update id, props, (savedDocument) ->
    socket.emit 'document:update', savedDocument
    callback null, savedDocument

# DELETE
exports.destroy = (data, callback, socket) ->
  id = data._id
  console.log "Delete Document Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () ->
      socket.emit 'document:delete', true
      callback null, node
