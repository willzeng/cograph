class GraphModel extends Backbone.Model
  initialize: ->
    nodes = Backbone.Collection.extend model: Node
    connections = Backbone.Collection.extend model: Connection
    @set "nodes", nodes
    @set "connections", connections

  getNodes: ->
    return @get "nodes"

  getConnections: ->
    return @get "links"
