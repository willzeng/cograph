define ['jquery', 'underscore', 'backbone', 'cs!controllers/DataController', 'cs!views/DetailsView'],
($, _, Backbone, DataController, DetailsView) ->
  class DataHub extends Backbone.View

    initialize: ->
      @model.nodes.on 'add', @nodeAdd, this
      @model.nodes.on 'change', @nodeEdit, this
      @model.on 'delete:node', @nodeDelete, this
      @model.connections.on 'add', @connectionAdd, this
      @model.connections.on 'change', @connectionEdit, this
      @model.on 'delete:connection', @connectionDelete, this


    nodeAdd: (node) ->
      if node.get('_id') < 0
        DataController.nodeAdd node, (newNode) ->
          node.set '_id', newNode._id

    connectionAdd: (connection) ->
      if connection.get('_id') < 0
        DataController.connectionAdd connection, (newConn) ->
          connection.set '_id', newConn._id

    nodeEdit: (node) ->
      if not _.isEmpty _.omit(node.changed, node.ignoredAttributes)
        if node.get('_id') >= 0
          DataController.nodeEdit node

    connectionEdit: (conn) ->
      if _.difference(_.keys(conn.changed), conn.ignoredAttributes).length
        if conn.get('_id') >= 0
          DataController.connectionEdit conn

    nodeDelete: (node) ->
      DataController.objDelete 'node', node

    connectionDelete: (conn) ->
      DataController.objDelete 'connection', conn
