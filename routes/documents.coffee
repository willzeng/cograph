url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

# CREATE
exports.create = (req, resp) ->
  console.log 'create document query requested'
  newDocument = req.body
  node = graphDb.createNode newDocument
  label = "_Document"
  node.save (err, node) ->
    utils.setLabel graphDb, node.id, label, (err, savedNode) ->
      resp.send savedNode

# READ
exports.read = (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    resp.send node

exports.getAll = (req, resp) ->
  console.log "Get all Documents Query Requested"
  docLabel = '_Document'
  cypherQuery = "match (n:#{docLabel}) return n;"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then console.log err
    nodes = (utils.parseCypherResult(node, 'n') for node in results)
    resp.send nodes

# UPDATE
exports.update = (req, resp) ->
  id = req.body._id
  newData = req.body
  graphDb.getNodeById id, (err, node) ->
    node.data = newData
    node.save (err, node) ->
      console.log 'Document updated in database with id:', node._id
      resp.send node

# DELETE
exports.destroy = (req, resp) ->
  id = req.body._id
  console.log "Delete Document Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> true
