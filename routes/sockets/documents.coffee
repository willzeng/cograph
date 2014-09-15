url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require '../../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require '../utils'

DocumentHelper = require '../helpers/DocumentHelper'
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
      console.error 'Something broke!', err
    else
      parsed = utils.parseNodeToClient node._data.data
      socket.emit 'document:read', parsed
      callback null, parsed

exports.readCollection = (data, callback, socket) ->
  serverDocument.getAll (docs) ->
    socket.emit 'documents:read', docs
    callback null, docs

# UPDATE
exports.update = (data, callback, socket) ->
  id = data._id
  props = data
  serverDocument.update id, props, (savedDocument) ->
    socket.emit 'document:update', savedDocument
    socket.broadcast.to(savedDocument._id).emit 'document:update', savedDocument
    callback null, savedDocument

# DELETE
exports.destroy = (data, callback, socket) ->
  id = data._id
  console.log "Delete Document Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () ->
      socket.emit 'document:delete', true
      callback null, node
