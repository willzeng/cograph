url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

NodeHelper = require __dirname + '/helpers/NodeHelper'
serverNode = new NodeHelper(graphDb)

# CREATE
exports.create = (req, resp) ->
  docLabel = "_doc_#{req.params.docId || 0}"
  tags = req.body.tags || []
  delete req.body.tags
  props = req.body
  serverNode.create tags, props, docLabel, (savedNode) ->
    resp.send savedNode

# READ
exports.read = (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    parsed = node._data.data
    utils.getLabels graphDb, id, (labels) ->
      parsed.tags = labels
      serverNode.getNeighbors id, (neighbors) ->
        parsed.neighborCount = neighbors.length
        resp.send utils.parseNodeToClient parsed

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
  cypherQuery = "START n=node({id}) MATCH (n)<-->(m) OPTIONAL MATCH (m)<-->(k) RETURN m, labels(m), count(k) AS neighborCount;"
  graphDb.query cypherQuery, params, (err, results) ->
    parsedNodes = []
    for node in results
      nodeData = node.m._data.data
      nodeData.tags = node['labels(m)']
      nodeData.neighborCount = node.neighborCount
      parsedNodes.push utils.parseNodeToClient nodeData
    resp.send parsedNodes

exports.getSpokes = (req, resp) ->
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-[r]->(m) RETURN r;"
  console.log cypherQuery
  graphDb.query cypherQuery, params, (err, results) ->
    connections = (utils.parseCypherResult(conn, 'r') for conn in results)
    resp.send connections

# UPDATE
exports.update = (req, resp) ->
  id = req.params.id
  newData = req.body
  tags = req.body.tags || ""
  delete req.body.tags
  props = req.body
  serverNode.update id, tags, props, (newNode) ->
    resp.send newNode

# DELETE
exports.destroy = (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> resp.send true

# OTHER

# Request is of the form {nodeIds: {id0, id1, ...}}
# returns all of the connections between node and any of the nodes
exports.getConnections = (request,response) ->
  id = request.params.id
  nodeIds = request.body.nodeIds
  if !(nodeIds?) then response.send "error"
  utils.get_connections graphDb, id, nodeIds, (conns) ->
    response.send conns
