define ['jquery', 'underscore', 'backbone', 'text!templates/data_tooltip.html'],
  ($, _, Backbone, dataTooltipTemplate) ->
    class DataTooltip extends Backbone.View
      el: $ '#graph'

      events:
        'mousemove svg' : 'trackCursor'

      initialize: ->
        @model.nodes.on 'remove', @emptyTooltip, this

        @graphView = @attributes.graphView
        @graphView.on 'node:mouseover connection:mouseover', (nc) =>
          @showToolTip nc

        @graphView.on 'node:mouseover', (node) =>
          @highlight node

        @graphView.on 'node:mouseout node:right-click connection:mouseout', (nc) =>
          window.clearTimeout(@isHoveringANode)
          window.clearTimeout(@highlightTimer)
          @model.dehighlight()
          @emptyTooltip()

      highlight: (node) ->
        connectionsToHL = @model.connections.filter (c) ->
          (c.get('source').cid is node.cid) or (c.get('target').cid is node.cid)

        nodesToHL = _.flatten connectionsToHL.map (c) -> [c.get('source'), c.get('target')]
        nodesToHL.push node

        @highlightTimer = setTimeout () =>
            @model.highlight(nodesToHL, connectionsToHL)
          , 600

      trackCursor: (event) ->
        $(".data-tooltip-container")
              .css('left',event.clientX)
              .css('top',event.clientY-20)

      showToolTip: (nodeConnection) ->
        @isHoveringANode = setTimeout( () ->
          $(".data-tooltip-container")
            .html(_.template(dataTooltipTemplate, nodeConnection))
            .fadeIn()
        , 600)

      emptyTooltip: ->
        $(".data-tooltip-container").fadeOut(200).empty()
