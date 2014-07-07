documents = require './documents'
nodes = require './nodes'

exports.socketServer = (app, server) ->

  app.http().io()

  app.io.sockets.on 'connection', (socket) ->
  
    # Document
    socket.on 'document:create', (data, callback) -> documents.create data, callback, socket
    socket.on 'document:read',   (data, callback) -> documents.read data, callback, socket
    socket.on 'document:update', (data, callback) -> documents.update data, callback, socket
    socket.on 'document:delete', (data, callback) -> documents.destroy data, callback, socket

    # Documents
    socket.on 'documents:read',   (data, callback) -> documents.readCollection data, callback, socket

    # Node
    socket.on 'node:create', (data, callback) -> nodes.create JSON.parse(data), callback, socket
    socket.on 'node:read',   (data, callback) -> nodes.read data, callback, socket
    socket.on 'node:update', (data, callback) -> nodes.update JSON.parse(data), callback, socket
    socket.on 'node:delete', (data, callback) -> nodes.destroy JSON.parse(data), callback, socket
