define ['jquery', 'd3',  'underscore', 'backbone'],
  ($, d3, _, Backbone) ->
    class DataTooltip extends Backbone.View
      el: $ '#graph'

      events:
        'mouseenter .node-title-body' : 'showToolTip'
        'mouseenter .connection' : 'showToolTip'
        'click .node-archive': 'archiveObj'
        'click .node-expand': 'expandNode'
        'click .node-fix': 'toggleFix'

      initialize: ->
        @model.nodes.on 'remove', @emptyTooltip, this

        @graphView = @attributes.graphView

        @ignoreMouse = false

        @graphView.on 'node:mouseenter', (node) =>
          if !(@ignoreMouse) then @highlight node

        @graphView.on 'connection:mouseout', (conn) =>
          if !(@ignoreMouse) then @emptyTooltip()

        @graphView.on 'node:drag', () =>
          @ignoreMouse = true

        @graphView.on 'node:dragend', () =>
          @ignoreMouse = false

        @graphView.on 'node:mouseout node:right-click', (nc) =>
          if !(@ignoreMouse)
            @model.dehighlight()
            @emptyTooltip()

      highlight: (node) ->
        connectionsToHL = @model.connections.filter (c) ->
          (c.get('source') is node.get('_id')) or (c.get('target') is node.get('_id'))

        nodesToHL = _.flatten connectionsToHL.map (c) =>
          [@model.getSourceOf(c), @model.getTargetOf(c)]
        nodesToHL.push node

        @model.highlight(nodesToHL, connectionsToHL)

      showToolTip: (event) =>
        if !(@ignoreMouse)
          $(event.currentTarget).closest('.node').find('.node-info-body').addClass('shown')
          $(event.currentTarget).find('.connection-info-body').addClass('shown')
          # Set up correct tooltip hover
          $('.node-info-body').hover (e) ->
            nearestTitle = $(e.currentTarget.parentNode).siblings('.node-title').children()
            nearestTitle.addClass "filled-white"
          , (e) ->
            nearestTitle = $(e.currentTarget.parentNode).siblings('.node-title').children()
            nearestTitle.removeClass "filled-white"

      emptyTooltip: () ->
        $('.node-info-body').removeClass('shown')
        $('.connection-info-body').removeClass('shown')

      archiveObj: (event) ->
        removeId = parseInt $(event.currentTarget).attr("data-id")
        nc = @model.nodes.findWhere {_id:removeId}
        if nc.constructor.name is "NodeModel"
          @model.removeNode nc
        else if nc.constructor.name is "ConnectionModel"
          @model.removeConnection nc

      expandNode: (event) ->
        expandId = parseInt $(event.currentTarget).attr("data-id")
        expandedNode = @model.nodes.findWhere {_id:expandId}
        expandedNode.getNeighbors (neighbors) =>
          for node in neighbors
            newNode = new expandedNode.constructor node
            if @model.putNode newNode #this checks to see if the node has passed the filter
              newNode.getConnections @model.nodes, (connections) =>
                @model.putConnection new @model.connections.model conn for conn in connections

      toggleFix: (event) =>
        unfixId = parseInt $(event.currentTarget).attr("data-id")
        unfixNode = @model.nodes.findWhere {_id:unfixId}
        d3.select(event.currentTarget).classed('fixed', unfixNode.fixed = !unfixNode.fixed)
        @graphView.updateDetails()