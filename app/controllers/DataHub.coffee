define ['jquery', 'underscore', 'backbone', 'cs!controllers/DataController', 'cs!views/DetailsView'],
($, _, Backbone, DataController, DetailsView) ->
  class DataHub extends Backbone.View

    initialize: ->
      @model.nodes.on 'add', @nodeAdd, this
      @model.connections.on 'add', @connectionAdd, this
      @model.on 'delete:node', @nodeDelete, this
      @model.on 'delete:connection', @connectionDelete, this
      @model.nodes.on 'change', @nodeEdit, this

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

    nodeDelete: (node) ->
      DataController.objDelete 'node', node

    connectionDelete: (conn) ->
      DataController.objDelete 'connection', conn
