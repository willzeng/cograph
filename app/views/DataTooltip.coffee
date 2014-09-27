define ['jquery', 'd3',  'underscore', 'backbone', 'linkify'],
  ($, d3, _, Backbone, linkify) ->
    class DataTooltip extends Backbone.View
      el: $ '#graph'

      events:
        'mouseenter .node-title-span' : 'showToolTip'
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

        @graphView.on 'node:drag', () =>
          @ignoreMouse = true

        @graphView.on 'node:dragend', () =>
          @ignoreMouse = false

        @expandArrayed = false
        @graphView.on 'node:mouseout node:right-click', (nc) =>
          if !(@ignoreMouse)
            @model.dehighlight()
            @emptyTooltip()
          if @expandArrayed
            @graphView.updateForceGraph()
            @expandArrayed = false

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
          nodeContainer = $(event.currentTarget).closest('.node')
          p = nodeContainer.parent()
          nodeContainer.remove()
          p.append(nodeContainer)
          nodeContainer.find('.node-title-body').addClass('shown')
          nodeContainer.find('.node-info-body').addClass('shown').linkify()

          # set-up clickable tags
          $('.tag-link').on "click", (e) =>
            e.preventDefault()
            tag = $(e.currentTarget).attr('data-tag')
            @graphView.trigger 'tag:click', tag

      emptyTooltip: () ->
        $('.node-title-body').removeClass('shown')
        $('.node-info-body').removeClass('shown')

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
        # fix the expanded node in place
        expandedNode.set "fixed", true
        d3.select(event.currentTarget).classed('fixed', expandedNode.fixed = true)
        expandedNode.getNeighbors (neighbors) =>
          # create models
          expandedModels = _.map neighbors, (n) ->
            new expandedNode.constructor n
          expandedIds = _.map expandedModels, (nm) -> nm.get('_id')

          # add neighbor nodes to the graph at the pos of expandedNode
          _.each expandedModels, (nm) =>
            nm.fixed = true
            nm.x = expandedNode.x
            nm.y = expandedNode.y
            @model.putNode nm

          # transition neighbors into a circle around expandedNode
          transitionDuration = if options? and options.duration? then options.duration else 200
          circleFilter = (d,i) -> #determines if a node should be moved
            not d.get('fixed') and _.contains expandedIds, d.get('_id')
          #   find the nearest position in the circle
          positions = (@radialPosition(expandedNode, i, neighbors.length) for i in [1..neighbors.length])
          currPos = ([node.x, node.y] for node in @model.nodes.filter circleFilter)
          targets = {}
          _.each currPos, (d,i) =>
            distances = ([@distance(p, d), p] for p in positions)
            min = _.sortBy(distances, (d) -> d[0])[0][1]
            positions = positions.filter (p) -> not (p[0] is min[0] and p[1] is min[1])
            targets[i] = min

          theNodes = d3.select(".node-container").selectAll(".node").filter circleFilter
          theNodes.transition()
            .duration(transitionDuration)
            .attr "transform", (d, i) =>
              min = targets[i]
              d.targetPos = min
              "translate(#{min[0]},#{min[1]})"

          # find and transition connections for added neighbors
          _.each expandedModels, (nm) =>
            nm.getConnections @model.nodes, (connections) =>
              for conn in connections
                spoke = new @model.connections.model conn
                @model.putConnection spoke
                spokeSource = @model.getSourceOf(spoke)
                spokeTarget = @model.getTargetOf(spoke)
                if circleFilter spokeSource
                  @transitionConnection spoke, "source", spokeSource.targetPos, transitionDuration
                else if circleFilter spokeTarget
                  @transitionConnection spoke, "target", spokeTarget.targetPos, transitionDuration

          # following the transition, update the force positions of the nodes
          # and update details
          setTimeout =>
            movedModels = @model.nodes.filter circleFilter
            _.each movedModels, (nm, i) =>
              [nm.x,nm.y] = targets[i]
              [nm.px,nm.py] = [nm.x,nm.y]
              nm.set 'fixed', false
              nm.fixed = false
            @graphView.updateDetails()
            @expandArrayed = true
          , transitionDuration

      # direction sets which end of the connection is being transitioned
      # to dest
      transitionConnection: (conn, direction, dest, duration) ->
        connection = d3.select(".connection-container").selectAll(".connection").filter (c) ->
          c.get('_id') is conn.get('_id')
        if direction is "source"
          connection.selectAll("line").transition().duration(duration)
            .attr("x1", (d) => dest[0]-(@graphView.nodeBoxWidth/2+10))
            .attr("y1", (d) => dest[1])
          connection.select(".connection-text").transition().duration(duration)
            .attr("transform", (d) => "translate(#{((dest[0]-@model.getTargetOf(conn).x)/2+@model.getTargetOf(conn).x)-(@graphView.nodeBoxWidth/2+10)},#{(dest[1]-@model.getTargetOf(conn).y)/2+@model.getTargetOf(conn).y})")
        else if direction is "target"
          connection.selectAll("line").transition().duration(duration)
            .attr("x2", (d) => dest[0]-(@graphView.nodeBoxWidth/2+10))
            .attr("y2", (d) => dest[1])
          connection.select(".connection-text").transition().duration(duration)
            .attr("transform", (d) => "translate(#{((@model.getSourceOf(conn).x-dest[0])/2+dest[0])-(@graphView.nodeBoxWidth/2+10)},#{(@model.getSourceOf(conn).y-dest[1])/2+dest[1]})")

      distance: (p1, p2) ->
        Math.sqrt (p1[0]-p2[0])*(p1[0]-p2[0]) + (p1[1]-p2[1])*(p1[1]-p2[1])

      radialPosition: (centerNode, i, steps) ->
        radius = 160
        offset = Math.PI/4
        [centerNode.x + radius * Math.cos(2 * Math.PI * i / steps+offset), centerNode.y + radius * Math.sin(2 * Math.PI * i / steps+offset)]

      toggleFix: (event) =>
        console.log('Unfixing node')
        unfixId = parseInt $(event.currentTarget).attr("data-id")
        unfixNode = @model.nodes.findWhere {_id:unfixId}
        unfixNode.set 'fixed', !unfixNode.fixed
        d3.select(event.currentTarget).classed('fixed', unfixNode.fixed = !unfixNode.fixed)
        @graphView.updateForceGraph()
