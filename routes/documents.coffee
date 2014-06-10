express = require 'express'
nodes = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

#defines a function to extract parameters using regex's
documents.param utils.paramExtract

documents.param 'id', /^\d+$/

# CREATE
documents.post '/', (req, resp) ->
  newDocument = req.body
  node = graphDb.createNode newDocument
  label = "_Document"
  node.save (err, node) ->
    utils.setLabel graphDb, node.id, label, (err, node) ->
      newNode._id = node.id
      resp.send newNode

# READ
documents.get '/:id', (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    resp.send node

documents.get '/', (req, resp) ->
  console.log "Get all Documents Query Requested"
  docLabel = '_Document'
  cypherQuery = "match (n:#{docId}) return n;"
  params = {}
  graphDb.query cypherQuery, params, (err, results) ->
    if err then console.log err
    nodes = (utils.parseCypherResult(node, 'n') for node in results)
    resp.send nodes

# UPDATE
documents.put '/', (req, resp) ->
  id = req.body._id
  newData = req.body
  graphDb.getNodeById id, (err, node) ->
    node.data = newData
    node.save (err, node) ->
      console.log 'Document updated in database with id:', node._id
      resp.send node

# DELETE
nodes.delete '/', (req, resp) ->
  id = req.body._id
  console.log "Delete Document Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> true


module.exports = documents
