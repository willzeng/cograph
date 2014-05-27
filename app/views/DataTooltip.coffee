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

        @graphView.on 'node:mouseout node: right-click connection:mouseout', (nc) =>
          window.clearTimeout(@isHoveringANode)
          @model.dehighlightConnections()
          @model.dehighlightNodes()
          @emptyTooltip()

      trackCursor: (event) ->
        $(".data-tooltip-container")
              .css('left',event.clientX)
              .css('top',event.clientY-20)

      showToolTip: (nodeConnection) ->
        @isHoveringANode = setTimeout( () =>
          $(".data-tooltip-container")
            .html(_.template(dataTooltipTemplate, nodeConnection))
            .fadeIn()
        , 600)

      emptyTooltip: ->
        $(".data-tooltip-container").fadeOut(200).empty()
