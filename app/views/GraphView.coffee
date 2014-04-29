define ['jquery', 'underscore', 'backbone', 'd3', 'text!templates/node.html',
  'text!templates/node_circle.html'],
  ($, _, Backbone, d3, nodeTemplate, nodeCircleTemplate) ->
    class GraphView extends Backbone.View

      el: $ '#main-area'
      graph: $ '#graph'

      events:
        'submit #add-node-form': @add_node

      initialize: ->
        @model.nodes.on 'add', @update, this

      update: (node) ->
        $(@el).append _.template(nodeTemplate, node.attributes)
        nodeCircle = $ _.template(nodeCircleTemplate, node.attributes)
        $(@graph).append nodeCircle

      render: ->
        $(@el).append '<h2>More Header</h2>'
