define ['jquery', 'underscore', 'backbone', 'text!templates/data_tooltip.html'],
  ($, _, Backbone, dataTooltipTemplate) ->
    class DataTooltip extends Backbone.View
      el: $ '#graph'

      initialize: ->
        @graphView = @attributes.graphView
        @model.nodes.on 'remove', @emptyTooltip, this

        @isHoveringANode = @dataToolTipShown = false

        @graphView.on 'node:right-click', () ->
          $(".data-tooltip-container").empty()

        @graphView.on 'node:mouseover', (node) =>
          if !@dataToolTipShown
            @isHoveringANode = setTimeout( () =>
              @dataToolTipShown = true
              $(".data-tooltip-container")
                .append _.template(dataTooltipTemplate, node)
            ,200)

        @graphView.on 'node:mouseout', (node) =>
          window.clearTimeout(@isHoveringANode)
          if !@translateLock
            @model.dehighlightConnections()
            @model.dehighlightNodes()
            @emptyTooltip()

      emptyTooltip: ->
        @dataToolTipShown = false
        $(".data-tooltip-container").empty()
