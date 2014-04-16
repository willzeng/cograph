express = require 'express'

module.exports = class MyApp

  constructor:(@graphDb)->
    graphDb = @graphDb

    app = express()

    app.set 'views', __dirname + '/..'
    app.set 'view options', layout:false
    app.use express.static(__dirname+'/../views')

    app.get('/', (request, response)->
      response.render('index.jade')
    )
    app.listen(3000)
