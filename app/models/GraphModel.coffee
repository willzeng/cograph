define ['backbone', 'cs!models/NodeModel','cs!models/ConnectionModel'], (Backbone, NodeModel, ConnectionModel) ->
  class ConnectionCollection extends Backbone.Collection
    model: ConnectionModel

  class NodeCollection extends Backbone.Collection
    model: NodeModel

  class GraphModel extends Backbone.Model
    initialize: ->
      @nodes = new NodeCollection()
      @connections = new ConnectionCollection()

    putNode: (name) ->
      console.log "Added node with name #{name}"
      @nodes.add {'name': name}

    removeNode: (model) ->
      console.log "Removed node"
      @nodes.remove model

    putConnection: (name) ->
      console.log "Added connection with name #{name}"
      @connections.add {'name': name}

    selectNode: (node) ->
      @nodes.each (d) ->
        d.set('selected', false)
      @nodes.get(node).set 'selected', true

    removeConnection: (model) ->
      console.log "Removed connection"
      @connections.remove model