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

    putConnection: (name) ->
      console.log "Added connection with name #{name}"
      @connections.add {'name': name}

    selectNode: (node) ->
      @nodes.each (d) ->
        d.set('selected', false)
      @nodes.get(node).set 'selected', true

    highlightNodes: (nodesToHL) ->
      @nodes.each (d) ->
        d.set('dim',true)
      $.each(nodesToHL,(i,d) =>
        console.log i
        @nodes.get(d).set 'dim', false
      )

    dehighlightNodes: () ->
      @nodes.each (d) ->
        d.set('dim',false)