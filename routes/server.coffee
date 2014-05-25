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

server.post('/create_node', (request, response) ->
  newNode = request.body
  node = graphDb.createNode newNode
  node.save (err, node) ->
    console.log 'Node saved to database with id:', node.id
  response.send request.body
)

server.post('/create_connection', (request, response) ->
  newConnection = request.body
  source = request.body.source
  target = request.body.target
  console.log 'source is: ', source
  response.send ""
)

parseCypherNode = (node) ->
  nodeData = node.n._data.data
  nodeData.in_DB = true
  nodeData


module.exports = server
