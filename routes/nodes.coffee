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
