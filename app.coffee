express = require 'express.io'
path = require 'path'
favicon = require 'static-favicon'
bodyParser = require 'body-parser'
routes = require './routes/index'

app = express()

app.set 'views', __dirname + '/app/public'
app.set 'view engine', 'jade'

app.use favicon(path.join(__dirname, '/app/assets/images/favicon.ico'))
app.use require('less-middleware')(path.join(__dirname, '/app/') )
app.use bodyParser()

# this line must be after the less-middleware declaration
# http://stackoverflow.com/questions/19489681/node-js-less-middleware-not-auto-compiling
app.use express.static(path.join(__dirname, '/app'))

# set up traditional routes
app.use '/', routes

# set up real time routes
sockets = require './routes/sockets'
sockets.socketServer(app)

module.exports = app
