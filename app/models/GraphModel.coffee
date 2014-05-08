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
      console.log "Added node with name #{name}"
      @nodes.add {'name': name}

    putConnection: (name, source, target) ->
      console.log "Added connection with name #{name}"
      @connections.add {'name': name, 'source': source, 'target': target}

    selectNode: (node) ->
      @nodes.each (d) ->
        d.set('selected', false)
      @nodes.get(node).set 'selected', true

    getFilter: () ->
      @filterModel
