define ['backbone', 'cs!models/NodeModel'], (Backbone, NodeModel) ->

  class FilterModel extends Backbone.Model

    defaults:
      initial_tags: ["untagged"]
      node_tags: ["untagged"]
      connection_tags: []

    addInitialTags: (add) ->
      @set 'initial_tags', _.union(@get('initial_tags'), add)

    addNodeTags: (add) ->
      @set 'node_tags', _.union(@get('node_tags'), add)

    passes: (node) =>
      allowUntagged = _.contains @get('node_tags'), 'untagged'
      (_.intersection node.get('tags'), @get('node_tags')).length > 0 or ((node.get('tags').length is 0) and allowUntagged)
