define ['backbone', 'cs!models/NodeModel','cs!models/ConnectionModel','cs!models/FilterModel'], (Backbone, NodeModel, ConnectionModel, FilterModel) ->
  class ConnectionCollection extends Backbone.Collection
    model: ConnectionModel

  class NodeCollection extends Backbone.Collection
    model: NodeModel

  class GraphModel extends Backbone.Model
    initialize: ->
      @nodes = new NodeCollection()
      @connections = new ConnectionCollection()
      @filterModel = new FilterModel @get 'initial_tags'

      @filterModel.on "change", @filter

    filter: =>
      for node in @nodes.models
        if !(@filterModel.passes node)
          @nodes.remove node

    putNode: (nodeModel) ->
      if @filterModel.passes nodeModel
        @nodes.add nodeModel

    putConnection: (connectionModel) ->
      @connections.add connectionModel

    removeNode: (model) ->
      @nodes.remove model
      @connections.remove @connections.where {'source':model}
      @connections.remove @connections.where {'target':model}

    deleteNode: (model) ->
      @removeNode model
      @trigger 'delete:node', model

    deleteConnection: (model) ->
      @removeConnection model
      @trigger 'delete:connection', model

    removeConnection: (model) ->
      @connections.remove model

    selectNode: (node) ->
      @nodes.each (d) ->
        d.set('selected', false)
      @connections.each (d) ->
        d.set('selected', false)
      node.set 'selected', true

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

    getFilter: () ->
      @filterModel
