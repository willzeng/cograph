define ['backbone', 'js/NodeModel','js/ConnectionModel'], (Backbone, NodeModel, ConnectionModel) ->

  class GraphModel extends Backbone.Model
    initialize: ->
      nodes = []
      connections = Backbone.Collection.extend model: ConnectionModel
      @set "nodes", nodes
      @set "connections", connections

    getNodes: ->
      return @get "nodes"

    getConnections: ->
      return @get "links"

    putNode: (node) ->
      data = @get("nodes")
      data.push node
      @set "nodes", data
      console.log 'triggering change'
      @trigger 'change'
