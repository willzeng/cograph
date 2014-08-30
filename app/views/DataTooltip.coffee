define ['jquery', 'd3',  'underscore', 'backbone', 'linkify'],
  ($, d3, _, Backbone, linkify) ->
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
        @model.on 'found:node', @highlight, this

        @graphView = @attributes.graphView

        @ignoreMouse = false

        @graphView.on 'node:mouseenter', (node) =>
          @showToolTip(d3.event)
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
          @emptyTooltip()
          $(event.currentTarget).closest('.node').find('.node-title-body').addClass('shown')
          $(event.currentTarget).closest('.node').find('.node-info-body').addClass('shown').linkify()
          $(event.currentTarget).find('.connection-info-body').addClass('shown').linkify()

      emptyTooltip: () ->
        $('.node-title-body').removeClass('shown')
        $('.node-info-body').removeClass('shown')
        $('.connection-info-body').removeClass('shown')

      archiveObj: (event) ->
        removeId = parseInt $(event.currentTarget).attr("data-id")
        nc = @model.nodes.findWhere {_id:removeId}
        if nc.constructor.name is "NodeModel"
          @model.removeNode nc
        else if nc.constructor.name is "ConnectionModel"
          @model.removeConnection nc

      expandNode: (event, options) ->
        expandId = parseInt $(event.currentTarget).attr("data-id")
        expandedNode = @model.nodes.findWhere {_id:expandId}
        expandedNode.set "fixed", true
        d3.select(event.currentTarget).classed('fixed', expandedNode.fixed = true)
        expandedNode.getNeighbors (neighbors) =>
          # create models
          expandedModels = _.map neighbors, (n) ->
            new expandedNode.constructor n
          expandedIds = _.map expandedModels, (nm) -> nm.get('_id')

          # add neighbor nodes to the graph at the pos of expandedNode
          _.each expandedModels, (nm, i) =>
            nm.fixed = true
            nm.x = expandedNode.x
            nm.y = expandedNode.y
            if @model.putNode nm #this checks to see if the node has passed the filter
              nm.getConnections @model.nodes, (connections) =>
                @model.putConnection new @model.connections.model conn for conn in connections

          # transition neighbors into a circle around expandedNode
          transitionDuration = if options? and options.duration? then options.duration else 1000
          circleFilter = (d,i) -> #determines if a node should be moved
            not d.get('fixed') and _.contains expandedIds, d.get('_id')
          theNodes = d3.select(".node-container").selectAll(".node").filter circleFilter
          theNodes.transition()
            .duration(transitionDuration)
            .attr "transform", (d, i) =>
              pos = @radialPosition expandedNode, i, neighbors.length
              "translate(#{pos[0]},#{pos[1]})"

          # following the transition, update the force positions of the nodes
          # and update the forcegraph
          setTimeout =>
            movedModels = @model.nodes.filter circleFilter
            _.each movedModels, (nm, i) =>
              [nm.x,nm.y] = @radialPosition expandedNode, i, neighbors.length
              [nm.px,nm.py] = [nm.x,nm.y]
              nm.set 'fixed', true
              nm.fixed = true
            @graphView.updateForceGraph()
          , transitionDuration

      radialPosition: (centerNode, i, steps) ->
        radius = 160
        offset = Math.PI/4
        [centerNode.x + radius * Math.cos(2 * Math.PI * i / steps+offset), centerNode.y + radius * Math.sin(2 * Math.PI * i / steps+offset)]

      toggleFix: (event) =>
        unfixId = parseInt $(event.currentTarget).attr("data-id")
        unfixNode = @model.nodes.findWhere {_id:unfixId}
        unfixNode.set 'fixed', !unfixNode.fixed
        d3.select(event.currentTarget).classed('fixed', unfixNode.fixed = !unfixNode.fixed)
        @graphView.updateForceGraph()
