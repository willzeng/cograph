define ['jquery', 'underscore', 'backbone', 'text!templates/data_tooltip.html'],
  ($, _, Backbone, dataTooltipTemplate) ->
    class DataTooltip extends Backbone.View
      el: $ '#graph'

      events:
        'mousemove svg' : 'trackCursor'

      initialize: ->
        @graphView = @attributes.graphView
        @model.nodes.on 'remove', @emptyTooltip, this
        @dataToolTipShown = false

        @isHoveringANode = @dataToolTipShown = false

        @graphView.on 'node:right-click', () =>
          @emptyTooltip()

        @graphView.on 'node:mouseover connection:mouseover', (nc) =>
          @showToolTip nc

        @graphView.on 'node:mouseout connection:mouseout', (nc) =>
          window.clearTimeout(@isHoveringANode)
          if !@translateLock
            @model.dehighlightConnections()
            @model.dehighlightNodes()
            @emptyTooltip()

        @graphView.on 'connection:mouseover', (conn) =>
          @showToolTip conn

        @graphView.on 'connection:mouseout', (conn) =>
          window.clearTimeout(@isHoveringANode)
          @emptyTooltip()

      trackCursor: (event) ->
        $(".data-tooltip-container")
              .css('left',event.clientX)
              .css('top',event.clientY-20)

      showToolTip: (nodeConnection) ->
        if !@dataToolTipShown
          @isHoveringANode = setTimeout( () =>
            @dataToolTipShown = true
            $(".data-tooltip-container")
              .html(_.template(dataTooltipTemplate, nodeConnection))
              .fadeIn()
          ,400)

      emptyTooltip: ->
        @dataToolTipShown = false
        $(".data-tooltip-container").fadeOut(200).empty()
