url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require '../../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require '../utils'

WorkspaceHelper = require '../helpers/WorkspaceHelper'
serverWorkspace = new WorkspaceHelper(graphDb)

# CREATE
exports.create = (data, callback, socket) ->
  console.log 'create workspace query requested'
  newWorkspace = data
  serverWorkspace.create newWorkspace, (savedWorkspace) ->
    socket.emit('workspace:create', savedWorkspace)
    callback(null, savedWorkspace)

# READ
exports.read = (data, callback, socket) ->
  id = data._id
  graphDb.getNodeById id, (err, node) ->
    if err
      console.error 'Something broke!', err
    else
      parsed = utils.parseNodeToClient node._data.data
      socket.emit 'workspace:read', parsed
      callback null, parsed

# UPDATE
exports.update = (data, callback, socket) ->
  id = data._id
  props = data
  serverWorkspace.update id, props, (savedWorkspace) ->
    socket.emit 'workspace:update', savedWorkspace
    socket.broadcast.to(savedWorkspace._docId).emit 'workspace:update', savedWorkspace
    callback null, savedWorkspace

# DELETE
exports.destroy = (data, callback, socket) ->
  id = parseInt data._id
  graphDb.getNodeById id, (err, node) ->
    node.delete () ->
      parsed = node._data.data
    , true
    socket.emit 'workspace:delete', data
    socket.broadcast.to(data._docId).emit 'workspace:delete', data
