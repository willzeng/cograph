url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

NodeHelper = require __dirname + '/helpers/NodeHelper'
serverNode = new NodeHelper(graphDb)

# CREATE
exports.create = (data, callback, socket) ->
  docLabel = "_doc_#{data._docId || 0}"
  tags = data["tags"] || []
  delete data["tags"]
  props = data
  serverNode.create tags, props, docLabel, (savedNode) ->
    socket.emit('nodes:create', savedNode)
    # socket.broadcast.emit('documents:create', savedNode)
    callback(null, savedNode)

# READ
exports.read = (data, callback, socket) ->
  console.log "da data be", data
  if data.length > 0
    data = JSON.parse(data)
    id = data._id
    graphDb.getNodeById id, (err, node) ->
      parsed = node._data.data
      utils.getLabels graphDb, id, (labels) ->
        parsed.tags = labels
        parsed = utils.parseNodeToClient parsed
        console.log "emit", parsed
        socket.emit('node:read', parsed)
        # socket.broadcast.emit('documents:create', parsed)
        callback(null, parsed)

exports.readCollection = (data, callback, socket) ->
  console.log "read coll of nodes req", data
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
      parsedNodes.push utils.parseNodeToClient nodeData
    console.log "emit", parsedNodes
    socket.emit('nodes:read', parsedNodes)
    # socket.broadcast.emit('documents:create', parsedNodes)
    callback(null, parsedNodes)

exports.getAll = (req, resp) ->
  console.log "get_all_nodes Query Requested"
  docLabel = "_doc_#{req.params.docId || 0}"
  # SUPER UNSAFE, allows for SQL injection but node-neo4j wasn't interpolating
  cypherQuery = "match (n:#{docLabel}) return n, labels(n);"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then throw err
    parsedNodes = []
    for node in results
      nodeData = node.n._data.data
      nodeData.tags = node['labels(n)']
      parsedNodes.push utils.parseNodeToClient nodeData
    resp.send parsedNodes

exports.getNeighbors = (req, resp) ->
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-->(m) RETURN m, labels(m);"

  graphDb.query cypherQuery, params, (err, results) ->
    parsedNodes = []
    for node in results
      nodeData = node.m._data.data
      nodeData.tags = node['labels(m)']
      parsedNodes.push utils.parseNodeToClient nodeData
    resp.send parsedNodes

exports.getSpokes = (req, resp) ->
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-[r]->(m) RETURN r;"
  graphDb.query cypherQuery, params, (err, results) ->
    connections = (utils.parseCypherResult(conn, 'r') for conn in results)
    resp.send connections

# UPDATE
exports.update = (data, callback, socket) ->
  console.log "data for de updatin be", data
  id = data._id
  tags = data.tags || ""
  delete data.tags
  props = data
  serverNode.update id, tags, props, (newNode) ->
    console.log "emit:update", newNode
    socket.emit('node:update', newNode)
    # socket.broadcast.emit('documents:create', parsed)
    callback(null, newNode)

# DELETE
exports.destroy = (data, callback, socket) ->
  id = data._id
  graphDb.getNodeById id, (err, node) ->
    node.delete () ->
      socket.emit('node:delete', true)
      # socket.broadcast.emit('documents:create', parsed)
      callback(null, node)

# OTHER

# Request is of the form {node: id, nodes:{id0, id1, ...}}
# returns all of the connections between node and any of the nodes
exports.getConnections = (request,response) ->
  id = request.params.id
  nodeIds = request.body.nodeIds
  if !(nodeIds?) then response.send "error"
  utils.get_connections graphDb, id, nodeIds, (conns) ->
    response.send conns
