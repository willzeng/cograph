url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'

# load node_modules/neo4j folder and start graphDB instance
neo4j = require __dirname + '/node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url

express = require 'express'
path = require 'path'
favicon = require 'static-favicon'
bodyParser = require 'body-parser'

app = express()

app.set 'views', __dirname + '/app/public'
app.set 'view engine', 'jade'

app.use favicon(path.join(__dirname, '/app/assets/images/rhizi.ico'))
app.use require('less-middleware')(path.join(__dirname, '/app/') )

# this line must be after the less-middleware declaration
# http://stackoverflow.com/questions/19489681/node-js-less-middleware-not-auto-compiling
app.use express.static(path.join(__dirname, '/app'))

app.use bodyParser()

app.get('/', (request, response)->
  response.render('index.jade')
)

app.post('/create_node', (request, response) ->
  newNode = request.body
  node = graphDb.createNode newNode
  node.save (err, node) ->
    console.log 'Node saved to database with id:', node.id
  response.send request.body
)

module.exports = app
