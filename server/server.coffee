express = require 'express'

module.exports = class MyApp

  constructor:(@graphDb)->
    graphDb = @graphDb

    app = express()

    app.set 'views', __dirname + '/../views'
    app.set 'view options', layout:false
    app.use express.static(__dirname+'/../assets')

    app.get('/', (request, response)->
      response.render('index.jade')
    )
    app.listen(3000)
