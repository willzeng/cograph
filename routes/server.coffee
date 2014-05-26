express = require 'express'
server = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'

# load node_modules/neo4j folder and start graphDB instance
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url

server.get('/get_all_nodes', (request, response) ->
  console.log "get_all_nodes Query Requested"
  cypherQuery = "start n=node(*) return n;"
  graphDb.query cypherQuery, {}, (err, results) ->
    nodes = (parseCypherNode(node) for node in results)
    response.send nodes
)

server.get('/get_all_connections', (request, response) ->
  console.log "get_all_connections Query Requested"
  cypherQuery = "start n=rel(*) return n;"
  graphDb.query cypherQuery, {}, (err, results) ->
    connections = (parseCypherNode(connection) for connection in results)
    response.send connections
)

server.post('/create_node', (request, response) ->
  console.log "create_node Query Requested"
  newNode = request.body
  node = graphDb.createNode newNode
  node.save (err, node) ->
    console.log 'Node saved to database with id:', node.id
    newNode._id = node.id
    node.data._id = node.id
    node.save (err, node) ->
      console.log 'Updated id of node'
    response.send newNode
)

server.get '/get_node', (request, response) ->
  id = request.query.id
  graphDb.getNodeById id, (err, node) ->
    response.send node

server.post '/update_node', (request, response) ->
  id = request.body._id
  newData = request.body
  graphDb.getNodeById id, (err, node) ->
    node.data = newData
    node.save (err, node) ->
      console.log 'Node updated in database with id:', node._id
    response.send node

server.post('/create_connection', (request, response) ->
  console.log "create_connection Query Requested"
  newConnection = request.body
  graphDb.getNodeById newConnection.source, (err, source) ->
    graphDb.getNodeById newConnection.target, (err, target) ->
      source.createRelationshipTo target, 'connection', newConnection, (err, conn) ->
        newConnection._id = conn.id
        conn.data._id = conn.id
        conn.save (err, conn) ->
          console.log 'Updated id of connection'
        response.send newConnection
)

server.post('/delete_node', (request, response) ->
  console.log "delete_node Query Requested"
  deleteNode = request.body
  cypherQuery = "start n=node(#{deleteNode._id}) delete n;"
  graphDb.query cypherQuery, {}, (err, results) ->
    response.send true
)

parseCypherNode = (node) ->
  nodeData = node.n._data.data
  nodeData._id = trim node.n._data.self
  nodeData

#Trims a url i.e. 'http://localhost:7474/db/data/node/312' -> 312
trim = (string)->
  string.match(/[0-9]*$/)[0]

module.exports = server
