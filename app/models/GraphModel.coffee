define ['backbone', 'cs!models/NodeModel','cs!models/ConnectionModel','cs!models/FilterModel'], (Backbone, NodeModel, ConnectionModel, FilterModel) ->
  class ConnectionCollection extends Backbone.Collection
    model: ConnectionModel

  class NodeCollection extends Backbone.Collection
    model: NodeModel

  class GraphModel extends Backbone.Model
    initialize: ->
      @nodes = new NodeCollection()
      @connections = new ConnectionCollection()

      @filterModel = new FilterModel {nodes:@nodes}

    putNode: (name) ->
      @nodes.add {'name': name}

    putConnection: (name, source, target) ->
      @connections.add {'name': name, 'source': source, 'target': target}

    removeNode: (model) ->
      @nodes.remove model

    removeConnection: (model) ->
      @connections.remove model

    selectNode: (node) ->
      @nodes.each (d) ->
        d.set('selected', false)
      node.set 'selected', true

    highlightNodes: (nodesToHL) ->
      @nodes.each (d) ->
        d.set('dim',true)
      _.each nodesToHL, (d) =>
        d.set 'dim', false

    dehighlightNodes: () ->
      @nodes.each (d) ->
        d.set 'dim', false

    highlightConnections: (connectionsToHL) ->
      @connections.each (d) ->
        d.set('dim', true)
      _.each connectionsToHL, (d) =>
        d.set 'dim', false

    dehighlightConnections: () ->
      @connections.each (d) ->
        d.set 'dim', false

    getFilter: () ->
      @filterModel