url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

# CREATE
exports.create = (req, resp) ->
  newNode = req.body
  node = graphDb.createNode newNode
  docLabel = "_doc_id_#{req.params.docId || 0}"
  node.save (err, node) ->
    utils.setLabel graphDb, node.id, docLabel, (err, savedNode) ->
      resp.send savedNode

# READ
exports.read = (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    resp.send node

exports.getAll = (req, resp) ->
  console.log "get_all_nodes Query Requested"
  docLabel = "_doc_id_#{req.params.docId || 0}"
  # SUPER UNSAFE, allows for SQL injection but node-neo4j wasn't interpolating
  cypherQuery = "match (n:#{docLabel}) return n;"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then console.log err
    nodes = (utils.parseCypherResult(node, 'n') for node in results)
    resp.send nodes

exports.getNeighbors = (req, resp) ->
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-->(m) RETURN m"
  graphDb.query cypherQuery, params, (err, results) ->
    nodes = (utils.parseCypherResult(node, 'm') for node in results)
    resp.send nodes

exports.getSpokes = (req, resp) ->
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-[r]->(m) RETURN r;"
  graphDb.query cypherQuery, params, (err, results) ->
    connections = (utils.parseCypherResult(conn, 'r') for conn in results)
    resp.send connections

# UPDATE
exports.update = (req, resp) ->
  id = req.params.id
  newData = req.body
  graphDb.getNodeById id, (err, node) ->
    node.data = newData
    node.save (err, node) ->
      console.log 'Node updated in database with id:', node._id
      resp.send node

# DELETE
exports.destroy = (req, resp) ->
  id = req.params.id
  console.log "delete_node Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> true
