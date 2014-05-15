define ['backbone', 'cs!models/NodeModel'], (Backbone, NodeModel) ->

  class FilterModel extends Backbone.Model

    passes: (node) =>
      (_.intersection node.get('tags'), @get('node_tags')).length > 0 or (node.get('tags').length is 0)
