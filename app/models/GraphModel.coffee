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
      return @nodes.add {'name': name}

    removeNode: (model) ->
      @nodes.remove model

    putConnection: (name, source, target) ->
      console.log "Added connection with name #{name}"
      return @connections.add {'name': name, 'source': source, 'target': target}

    selectNode: (node) ->
      @nodes.each (d) ->
        d.set('selected', false)
      @connections.each (d) ->
        d.set('selected', false)
      node.set 'selected', true

    removeConnection: (model) ->
      @connections.remove model

    selectConnection: (connection) ->
      @connections.each (d) ->
        d.set('selected', false)
      @nodes.each (d) ->
        d.set('selected', false)
      connection.set 'selected', true

    highlightNodes: (nodesToHL) ->
      @nodes.each (d) ->
        d.set('dim',true)
      _.each nodesToHL, (d) ->
        d.set 'dim', false

    dehighlightNodes: () ->
      @nodes.each (d) ->
        d.set 'dim', false

    highlightConnections: (connectionsToHL) ->
      @connections.each (d) ->
        d.set('dim', true)
      _.each connectionsToHL, (d) ->
        d.set 'dim', false

    dehighlightConnections: () ->
      @connections.each (d) ->
        d.set 'dim', false
