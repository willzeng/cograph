express = require 'express'
nodes = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

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
    resp.send utils.parseNodeToClient newNode

# READ
nodes.get '/:id', (req, resp) ->
  id = req.params.id
  graphDb.getNodeById id, (err, node) ->
    utils.getLabels graphDb, id, (labels) ->
      parsed = node._data.data
      parsed.tags = labels
      resp.send utils.parseNodeToClient parsed

nodes.get '/', (req, resp) ->
  console.log "get_all_nodes Query Requested"
  cypherQuery = "start n=node(*) return n, labels(n);"

  graphDb.query cypherQuery, {}, (err, results) ->
    parsedNodes = []
    for node in results
      nodeData = node.n._data.data
      nodeData.tags = node['labels(n)']
      parsedNodes.push utils.parseNodeToClient nodeData
    resp.send parsedNodes

nodes.get '/neighbors/:id', (req, resp) ->
  params = {id: req.params.id}
  cypherQuery = "START n=node({id}) MATCH (n)<-->(m) RETURN m, labels(m);"

  graphDb.query cypherQuery, params, (err, results) ->
    parsedNodes = []
    for node in results
      nodeData = node.m._data.data
      nodeData.tags = node['labels(m)']
      parsedNodes.push utils.parseNodeToClient nodeData
    resp.send parsedNodes

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
  tags = req.body.tags || ""
  delete req.body.tags
  props = req.body

  utils.updateNode graphDb, id, tags, props, (newNode) ->
    resp.send utils.parseNodeToClient newNode

# DELETE
nodes.delete '/:id', (req, resp) ->
  id = req.params.id
  console.log "delete_node Query Requested"
  graphDb.getNodeById id, (err, node) ->
    node.delete () -> true

# OTHER

# Request is of the form {node: id, nodes:{id0, id1, ...}}
# returns all of the connections between node and any of the nodes
nodes.post '/get_connections/:id', (request,response) ->
  console.log "GET Conections REQUESTED"
  id = request.body.node
  nodes = request.body.nodes
  if !(nodes?) then response.send "error"

  utils.get_connections graphDb, id, nodes, (conns) ->
    response.send conns

module.exports = nodes
