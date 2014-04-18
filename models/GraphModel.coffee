define ['js/NodeModel','js/ConnectionModel'], (NodeModel, ConnectionModel) ->

  class GraphModel extends Backbone.Model
    init: ->
      #@nodes = Backbone.Collection.extend model: NodeModel
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
      @trigger "change"

    # putLink: (link) ->
    #   @pushDatum "links", link

    # pushDatum: (attr, datum) ->
    #   console.log "push the following", attr, datum
    #   data = @get(attr)
    #   console.log "data", data
    #   data.push datum
    #   @set attr, data
