express = require 'express'
path = require 'path'
favicon = require 'static-favicon'

module.exports = class MyApp

  constructor:(@graphDb)->
    graphDb = @graphDb

    app = express()

    app.set 'views', __dirname + '/../views'
    app.set 'view engine', 'jade'

    app.use favicon(path.join(__dirname, '/../assets/images/rhizi.ico'))
    app.use require('less-middleware')(path.join(__dirname, '/../assets/') )

    # this line must be after the less-middleware declaration
    # http://stackoverflow.com/questions/19489681/node-js-less-middleware-not-auto-compiling
    app.use express.static(__dirname+'/../assets')

    app.get('/', (request, response)->
      response.render('index.jade')
    )
    app.listen(3000)
