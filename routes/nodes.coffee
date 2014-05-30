express = require 'express'
nodes = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

nodes.param 'id', (req, res, next, id) ->
  req.id = id
  next()

# CREATE
nodes.post '/', (req, resp) ->
  newNode = req.body
  node = graphDb.createNode newNode
  node.save (err, node) ->
    newNode._id = node.id
    node.data._id = node.id
    node.save (err, node) ->
      console.log 'Updated id of node'
    resp.send newNode

# READ
nodes.get '/:id', (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    resp.send node

nodes.get '/', (req, resp) ->
  console.log "get_all_nodes Query Requested"
  cypherQuery = "start n=node(*) return n;"
  graphDb.query cypherQuery, {}, (err, results) ->
    nodes = (utils.parseCypherResult(node, 'n') for node in results)
    resp.send nodes

# UPDATE
nodes.put '/', (req, resp) ->
  id = req.body._id
  newData = req.body
  graphDb.getNodeById id, (err, node) ->
    node.data = newData
    node.save (err, node) ->
      console.log 'Node updated in database with id:', node._id
    resp.send node

# DELETE
nodes.delete '/', (req, resp) ->
  id = req.body._id
  console.log "delete_node Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> true


module.exports = nodes
