documents = require './documents'
nodes = require './nodes'
connections = require './connections'

exports.socketServer = (app, server) ->

  app.http().io()

  app.io.sockets.on 'connection', (socket) ->

    # Rooms
    socket.on 'open:document', (doc, callback) ->
        docId = doc._id
        socket.join docId

    # Document
    socket.on 'document:create', (data, callback) -> documents.create data, callback, socket
    socket.on 'document:read',   (data, callback) -> documents.read data, callback, socket
    socket.on 'document:update', (data, callback) -> documents.update data, callback, socket
    socket.on 'document:delete', (data, callback) -> documents.destroy data, callback, socket

    # Documents
    socket.on 'documents:read',   (data, callback) -> documents.readCollection data, callback, socket

    # Node
    socket.on 'node:create', (data, callback) -> nodes.create data, callback, socket
    socket.on 'node:read',   (data, callback) -> nodes.read data, callback, socket
    socket.on 'node:update', (data, callback) -> nodes.update data, callback, socket
    socket.on 'node:delete', (data, callback) -> nodes.destroy data, callback, socket

    # Nodes
    socket.on 'nodes:read',   (data, callback) -> nodes.readCollection data, callback, socket

    # Connection
    socket.on 'connection:create', (data, callback) -> connections.create data, callback, socket
    socket.on 'connection:read',   (data, callback) -> connections.read data, callback, socket
    socket.on 'connection:update', (data, callback) -> connections.update data, callback, socket
    socket.on 'connection:delete', (data, callback) -> connections.destroy data, callback, socket

    # Connections
    socket.on 'connections:read',   (data, callback) -> connections.readCollection data, callback, socket
