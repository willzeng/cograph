define ['jquery', 'd3',  'underscore', 'backbone', 'text!templates/data_tooltip_node.html', 'text!templates/data_tooltip_connection.html'],
  ($, d3, _, Backbone, dataTooltipTemplateNode, dataTooltipTemplateConnection) ->
    class DataTooltip extends Backbone.View
      el: $ '#graph'

      events:
        'mouseenter .node-title-body' : 'showToolTip'
        'mouseenter .connection' : 'showToolTip'

      initialize: ->
        @model.nodes.on 'remove', @emptyTooltip, this

        @graphView = @attributes.graphView

        @graphView.on 'node:mouseenter', (node) =>
          @highlight node

        @graphView.on 'connection:mouseout', (conn) =>
          @emptyTooltip()

        @graphView.on 'node:mouseout node:right-click', (nc) =>
          window.clearTimeout(@highlightTimer)
          @model.dehighlight()
          @emptyTooltip()

      highlight: (node) ->
        connectionsToHL = @model.connections.filter (c) ->
          (c.get('source') is node.get('_id')) or (c.get('target') is node.get('_id'))

        nodesToHL = _.flatten connectionsToHL.map (c) =>
          [@model.getSourceOf(c), @model.getTargetOf(c)]
        nodesToHL.push node

        @highlightTimer = setTimeout () =>
            @model.highlight(nodesToHL, connectionsToHL)
          , 600

      showToolTip: (event) ->
        $(event.currentTarget).closest('.node').find('.node-info-body').addClass('shown')
        $(event.currentTarget).find('.connection-info-body').addClass('shown')

      emptyTooltip: () ->
        $('.node-info-body').removeClass('shown')
        $('.connection-info-body').removeClass('shown')
