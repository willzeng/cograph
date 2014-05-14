define ['backbone', 'cs!models/NodeModel'], (Backbone, NodeModel) ->

  class FilterModel extends Backbone.Model
    
    initialize: (attributes) ->
      @nodes = attributes.nodes
      @nodes.on 'add', @update, this
      @nodes.on 'change', @update, this

      @set 'node_tags', []

    update: ->
      @set 'node_tags', _.flatten _.union @nodes.pluck('tags')
