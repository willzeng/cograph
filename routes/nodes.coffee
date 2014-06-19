url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

# CREATE
exports.create = (req, resp) ->
  console.log "create requested"
  newNode = req.body
  node = graphDb.createNode newNode
  docLabel = "_doc_#{req.params.docId || 0}"
  tags = req.body.tags || ""
  delete req.body.tags
  props = req.body
  utils.createNode graphDb, tags, props, (newNode) ->
    utils.setLabel graphDb, newNode._id, docLabel, (savedNode) ->
      resp.send utils.parseNodeToClient savedNode

# READ
exports.read = (req, resp) ->
  console.log "read requested"
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    parsed = node._data.data
    utils.getLabels graphDb, id, (labels) ->
      parsed.tags = labels
      resp.send utils.parseNodeToClient parsed

exports.getAll = (req, resp) ->
  console.log "get_all_nodes Query Requested"
  docLabel = "_doc_#{req.params.docId || 0}"
  # SUPER UNSAFE, allows for SQL injection but node-neo4j wasn't interpolating
  cypherQuery = "match (n:#{docLabel}) return n, labels(n);"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then console.log err
    parsedNodes = []
    for node in results
      nodeData = node.n._data.data
      nodeData.tags = node['labels(n)']
      parsedNodes.push utils.parseNodeToClient nodeData
    resp.send parsedNodes

exports.getNeighbors = (req, resp) ->
  console.log "get getNeighbors requested"
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
  console.log "getSpokes requested"
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-[r]->(m) RETURN r;"
  graphDb.query cypherQuery, params, (err, results) ->
    connections = (utils.parseCypherResult(conn, 'r') for conn in results)
    resp.send connections

# UPDATE
exports.update = (req, resp) ->
  console.log "update requested"
  id = req.params.id
  newData = req.body
  tags = req.body.tags || ""
  delete req.body.tags
  props = req.body

  utils.updateNode graphDb, id, tags, props, (newNode) ->
    resp.send utils.parseNodeToClient newNode

# DELETE
exports.destroy = (req, resp) ->
  id = req.params.id
  console.log "delete_node Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> true

# OTHER

# Request is of the form {node: id, nodes:{id0, id1, ...}}
# returns all of the connections between node and any of the nodes
exports.getConnections = (request,response) ->
  console.log "GET Conections REQUESTED"
  id = request.body.node
  nodes = request.body.nodes
  if !(nodes?) then response.send "error"
  utils.get_connections graphDb, id, nodes, (conns) ->
    response.send conns
