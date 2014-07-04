url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

DocumentHelper = require __dirname + '/helpers/DocumentHelper'
serverDocument = new DocumentHelper graphDb

# CREATE
exports.create = (req, resp) ->
  console.log 'create document query requested'
  newDocument = req.body
  serverDocument.create newDocument, (savedDocument) ->
    resp.send savedDocument

# READ
exports.read = (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    if err then resp.send 500, 'Something broke!'
    else
      parsed = node._data.data
      resp.send utils.parseNodeToClient parsed

exports.getAll = (req, resp) ->
  console.log "Get all Documents Query Requested"
  docLabel = '_document'
  cypherQuery = "match (n:#{docLabel}) return n;"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then console.log err
    nodes = (utils.parseCypherResult(node, 'n') for node in results)
    resp.send nodes

# UPDATE
exports.update = (req, resp) ->
  id = req.params.id
  props = req.body
  serverDocument.update id, props, (savedDocument) ->
    resp.send savedDocument

# DELETE
exports.destroy = (req, resp) ->
  id = req.params.id
  console.log "Delete Document Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> true
