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
      @nodes.add {'name': name}

    removeNode: (model) ->
      @nodes.remove model

    putConnection: (name, source, target) ->
      @connections.add {'name': name, 'source': source, 'target': target}

    selectNode: (node) ->
      @nodes.each (d) ->
        d.set('selected', false)
      @nodes.get(node).set 'selected', true

    removeConnection: (model) ->
      @connections.remove model
