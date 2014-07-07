documents = require './documents'
nodes = require './nodes'

exports.socketServer = (app, server) ->

  app.http().io()

  app.io.sockets.on 'connection', (socket) ->
  
    # Documents
    socket.on 'documents:create', (data, callback) -> documents.create data, callback, socket
    socket.on 'documents:read',   (data, callback) -> documents.read data, callback, socket
    socket.on 'documents:update', (data, callback) -> documents.update data, callback, socket
    socket.on 'documents:delete', (data, callback) -> documents.destroy data, callback, socket

    # Nodes
    socket.on 'nodes:create', (data, callback) -> nodes.create JSON.parse(data), callback, socket
    socket.on 'nodes:read',   (data, callback) -> nodes.read data, callback, socket
    socket.on 'nodes:update', (data, callback) -> nodes.update JSON.parse(data), callback, socket
    socket.on 'nodes:delete', (data, callback) -> nodes.destroy JSON.parse(data), callback, socket
