define ['backbone', 'cs!models/NodeModel'], (Backbone, NodeModel) ->

  class FilterModel extends Backbone.Model

    node_tags: []
    connection_tags: []

    addNodeTags: (add) ->
      @set 'node_tags', _.union(@get('node_tags'), add)

    passes: (node) =>
      (_.intersection node.get('tags'), @get('node_tags')).length > 0 or (node.get('tags').length is 0)
