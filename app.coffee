url = 'http://wikinets-edge:wiKnj2gYeYOlzWPUcKYb@wikinetsedge.sb01.stations.graphenedb.com:24789';

# load node_modules/neo4js folder
neo4js = require(__dirname + '/node_modules/neo4js')
graphDb = new neo4js.GraphDatabase4Node(url)

express = require 'express'
path = require 'path'
favicon = require 'static-favicon'

app = express()

app.set 'views', __dirname + '/app/public'
app.set 'view engine', 'jade'

app.use favicon(path.join(__dirname, '/app/assets/images/rhizi.ico'))
app.use require('less-middleware')(path.join(__dirname, '/app/assets/') )

# this line must be after the less-middleware declaration
# http://stackoverflow.com/questions/19489681/node-js-less-middleware-not-auto-compiling
app.use express.static(path.join(__dirname, '/app'))

app.get('/', (request, response)->
  response.render('index.jade')
)

module.exports = app
