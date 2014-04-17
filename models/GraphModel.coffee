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

  putNode: (node) ->
    @pushDatum "nodes", node

  putLink: (link) ->
    @pushDatum "links", link

  pushDatum: (attr, datum) ->
    data = @get(attr)
    data.push datum
    @set attr, data

