express = require 'express'
nodes = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

connections.param 'id', (req, res, next, id) ->
  req.id = id
  next()

# CREATE
nodes.post '/', (req, resp) ->
  console.log "create_node Query Requested"
  newNode = req.body
  node = graphDb.createNode
  node.save (err, node) ->
    console.log 'Node saved to database with id:', node.id
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
    nodes = (utils.parseCypherNode(node) for node in results)
    resp.send nodes

# UPDATE
nodes.post '/:id', (req, resp) ->
  id = req.params.id
  newData = req.body
  graphDb.getNodeById id, (err, node) ->
    node.data = newData
    node.save (err, node) ->
      console.log 'Node updated in database with id:', node._id
    resp.send node

# DELETE
nodes.delete '/:id', (req, resp) ->
  id = req.params.id
  console.log "delete_node Query Requested"
  deleteNode = req.body
  cypherQuery = "start n=node(#{deleteNode._id}) delete n;"
  graphDb.query cypherQuery, {}, (err, results) ->
    resp.send true

module.exports = nodes
