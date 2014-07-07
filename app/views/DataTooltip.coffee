define ['jquery', 'd3',  'underscore', 'backbone', 'text!templates/data_tooltip.html'],
  ($, d3, _, Backbone, dataTooltipTemplate) ->
    class DataTooltip extends Backbone.View
      el: $ '#graph'

      events:
        'mousemove svg' : 'trackCursor'
        'mouseover .node' : 'showToolTip'
        'mouseover .connection' : 'showToolTip'

      initialize: ->
        @model.nodes.on 'remove', @emptyTooltip, this

        @graphView = @attributes.graphView

        @graphView.on 'node:mouseover', (node) =>
          @highlight node

        @graphView.on 'node:mouseout node:right-click connection:mouseout', (nc) =>
          window.clearTimeout(@isHoveringANode)
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

      trackCursor: (event) ->
        $(".data-tooltip-container")
          .css('left',event.clientX)
          .css('top',event.clientY-20)

      showToolTip: (event) ->
        @isHoveringANode = setTimeout( () =>
          $(event.currentTarget).find('.node-info-body').addClass('shown')
          $(event.currentTarget).find('.connection-info-body').addClass('shown')
        , 600)

      emptyTooltip: () ->
        $('.node-info-body').removeClass('shown')
        $('.connection-info-body').removeClass('shown')
