express = require 'express'
nodes = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

async = require __dirname + '/../node_modules/async'

#defines a function to extract parameters using regex's
nodes.param (name, fn) ->
  if fn instanceof RegExp
    return (req, res, next, val) ->
      if captures = fn.exec String(val)
        req.params[name] = captures
        next()
      else
        next 'route'

nodes.param 'id', /^\d+$/

# CREATE
nodes.post '/', (req, resp) ->
  if req.body.tags then tags = req.body.tags else tags = ""
  delete req.body.tags
  props = req.body

  utils.createNode graphDb, tags, props, (newNode) ->
    utils.nodeSet graphDb, newNode, '_id', newNode._id, (savedNode) ->
      resp.send savedNode

# READ
nodes.get '/:id', (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    utils.getLabels graphDb, id, (labels) ->
      parsed = node._data.data
      parsed.tags = labels
      resp.send parsed

nodes.get '/', (req, resp) ->
  console.log "get_all_nodes Query Requested"
  cypherQuery = "start n=node(*) return n;"

  iterator = (node, callback) ->
    utils.getLabels graphDb, node._id, (labels) ->
      node.tags = labels
      callback null, node

  graphDb.query cypherQuery, {}, (err, results) ->
    nodes = (utils.parseCypherResult(node, 'n') for node in results)
    async.map nodes, iterator, (err, labeled) ->
      resp.send labeled

nodes.get '/neighbors/:id', (req, resp) ->
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-->(m) RETURN m"
  graphDb.query cypherQuery, params, (err, results) ->
    nodes = (utils.parseCypherResult(node, 'm') for node in results)
    resp.send nodes

nodes.get '/spokes/:id', (req, resp) ->
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-[r]->(m) RETURN r;"
  graphDb.query cypherQuery, params, (err, results) ->
    connections = (utils.parseCypherResult(conn, 'r') for conn in results)
    resp.send connections

# UPDATE
nodes.put '/:id', (req, resp) ->
  id = req.params.id
  newData = req.body
  graphDb.getNodeById id, (err, node) ->
    node.data = newData
    node.save (err, node) ->
      console.log 'Node updated in database with id:', node.data._id
    resp.send node

# DELETE
nodes.delete '/:id', (req, resp) ->
  id = req.params.id
  console.log "delete_node Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> true


module.exports = nodes
