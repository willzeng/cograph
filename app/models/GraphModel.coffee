define ['backbone', 'cs!models/NodeModel','cs!models/ConnectionModel','cs!models/FilterModel'], (Backbone, NodeModel, ConnectionModel, FilterModel) ->
  class ConnectionCollection extends Backbone.Collection
    model: ConnectionModel
    url: 'connection'

  class NodeCollection extends Backbone.Collection
    model: NodeModel
    url: 'node'

  class GraphModel extends Backbone.Model
    initialize: ->
      @nodes = new NodeCollection()
      @connections = new ConnectionCollection()
      @filterModel = new FilterModel @get 'initial_tags'

      @filterModel.on "change", @filter

    filter: =>
      for node in @nodes.clone().models
        if !(@filterModel.passes node)
          @removeNode node

    putNode: (nodeModel) ->
      if @filterModel.passes nodeModel
        @nodes.add nodeModel
        true
      else
        false

    putConnection: (connectionModel) ->
      @connections.add connectionModel

    newConnectionCreated: ->
      @trigger 'create:connection'

    removeNode: (node) ->
      @connections.remove @connections.where {'source': node.get('_id')}
      @connections.remove @connections.where {'target': node.get('_id')}
      @nodes.remove node

    removeConnection: (model) ->
      @connections.remove model

    deleteNode: (model) ->
      @removeNode model
      model.destroy()

    deleteConnection: (model) ->
      @removeConnection model
      model.destroy()

    deSelect: (model) ->
      model.set 'selected', false

    select: (model) ->
      @nodes.each (d) => @deSelect d
      @connections.each (d) => @deSelect d
      model.set 'selected', true

    getSourceOf: (connection) ->
      @nodes.findWhere _id: connection.get('source')

    getTargetOf: (connection) ->
      @nodes.findWhere _id: connection.get('target')

    highlight: (nodesToHL, connectionsToHL) ->
      @nodes.each (d) ->
        d.set 'dim', true
      _.each nodesToHL, (d) ->
        d.set 'dim', false
      @connections.each (d) ->
        d.set 'dim', true
      _.each connectionsToHL, (d) ->
        d.set 'dim', false

    dehighlight: () ->
      @connections.each (d) ->
        d.set 'dim', false
      @nodes.each (d) ->
        d.set 'dim', false

    getFilter: () ->
      @filterModel
