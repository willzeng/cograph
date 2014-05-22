url = 'http://wikinets-edge:wiKnj2gYeYOlzWPUcKYb@wikinetsedge.sb01.stations.graphenedb.com:24789'
local = 'http://localhost:7474'

# load node_modules/neo4j folder and start graphDB instance
neo4j = require __dirname + '/node_modules/neo4j'
graphDb = new neo4j.GraphDatabase local

node = graphDb.createNode {hello: 'world'}
node.save (err, node) ->
  if err
    console.error 'Error saving new node to database:', err
  else
    console.log 'Node saved to database with id:', node.id

express = require 'express'
path = require 'path'
favicon = require 'static-favicon'

app = express()

app.set 'views', __dirname + '/app/public'
app.set 'view engine', 'jade'

app.use favicon(path.join(__dirname, '/app/assets/images/rhizi.ico'))
app.use require('less-middleware')(path.join(__dirname, '/app/') )

# this line must be after the less-middleware declaration
# http://stackoverflow.com/questions/19489681/node-js-less-middleware-not-auto-compiling
app.use express.static(path.join(__dirname, '/app'))

app.get('/', (request, response)->
  response.render('index.jade')
)

module.exports = app
