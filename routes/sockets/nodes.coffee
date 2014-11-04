url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require '../../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require '../utils'

NodeHelper = require '../helpers/NodeHelper'
serverNode = new NodeHelper(graphDb)

# CREATE
exports.create = (data, callback, socket) ->
  docLabel = "_doc_#{data._docId || 0}"
  tags = data["tags"] || []
  delete data["tags"]
  props = data
  serverNode.create tags, props, docLabel, (savedNode) ->
    savedNode.tags = tags
    socket.emit '/node:create', savedNode
    socket.broadcast.to(savedNode._docId).emit '/nodes:create', savedNode
    callback null, savedNode

# READ
exports.read = (data, callback, socket) ->
  id = data._id
  graphDb.getNodeById id, (err, node) ->
    parsed = node._data.data
    utils.getLabels graphDb, id, (labels) ->
      parsed.tags = labels
      parsed = utils.parseNodeToClient parsed
      serverNode.getNeighbors id, (neighbors) ->
        parsed.neighborCount = neighbors.length
        socket.emit '/node:read', parsed
        callback(null, parsed)

exports.readCollection = (data, callback, socket) ->
  console.log "readCollection of nodes in document #{data._docId}"
  docLabel = "_doc_#{data._docId || 0}"
  # SUPER UNSAFE, allows for SQL injection but node-neo4j wasn't interpolating
  cypherQuery = "match (n:#{docLabel}) return n, labels(n);"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then throw err
    parsedNodes = []
    for node in results
      nodeData = node.n._data.data
      nodeData.tags = node['labels(n)']
      serverNode.getNeighbors nodeData._id, (neighbors) ->
        nodeData.neighborCount = neighbors.length
        if parsedNodes.length is results.length-1
          parsedNodes.push utils.parseNodeToClient nodeData
          socket.emit '/nodes:read', parsedNodes
          callback null, parsedNodes  

# UPDATE
exports.update = (data, callback, socket) ->
  id = data._id
  tags = data.tags || ""
  delete data.tags
  props = data
  serverNode.update id, tags, props, (newNode) ->
    socket.emit '/node:update', newNode
    socket.broadcast.to(newNode._docId).emit '/nodes:update', newNode
    callback null, newNode

# DELETE
exports.destroy = (data, callback, socket) ->
  id = data._id
  graphDb.getNodeById id, (err, node) ->
    node.delete () ->
      parsed = node._data.data
      socket.emit '/nodes:delete', data
      socket.broadcast.to(parsed._docId).emit '/nodes:delete', parsed
      callback null, parsed
    , true

# OTHER
