documents = require './documents'

exports.socketServer = (app, server) ->

  app.http().io()

  app.io.sockets.on 'connection', (socket) ->
  
    # Documents
    socket.on 'documents:create', (data, callback) -> documents.create data, callback, socket
    socket.on 'documents:read',   (data, callback) -> documents.read data, callback, socket
    socket.on 'documents:update', (data, callback) -> documents.update data, callback, socket
    socket.on 'documents:delete', (data, callback) -> documents.destroy data, callback, socket
