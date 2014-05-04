define ['backbone', 'cs!models/NodeModel','cs!models/ConnectionModel'], (Backbone, NodeModel, ConnectionModel) ->
  class ConnectionCollection extends Backbone.Collection
    model: ConnectionModel

  class NodeCollection extends Backbone.Collection
    model: NodeModel

  class GraphModel extends Backbone.Model
    initialize: ->
      @nodes = new NodeCollection()
      @connections = new ConnectionCollection()

      @selectedNode = {}

    putNode: (name) ->
      console.log "Added node with name #{name}"
      @nodes.add {'name': name}

    putConnection: (name) ->
      console.log "Added connection with name #{name}"
      @connections.add {'name': name}

    selectNode: (node) ->
      @selectedNode = node
      @trigger "select:node", node
