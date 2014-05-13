define ['jquery', 'underscore', 'backbone', 'd3',
  'cs!views/ConnectionAdder', 'cs!views/TrashBin', 'cs!views/DataTooltip', 'cs!views/ZoomButtons'],
  ($, _, Backbone, d3, ConnectionAdder, TrashBin, DataTooltip, ZoomButtons) ->
    class GraphView extends Backbone.View
      el: $ '#graph'

      events:
        'click #sidebar-toggle': 'toggleSidebar'

      initialize: ->
        that = this
        @model.nodes.on 'add change remove', @update, this
        @model.connections.on 'add change remove', @update, this

        @sidebarShown = @translateLock = false

        width = $(@el).width()
        height = $(@el).height()

        @force = d3.layout.force()
                  .nodes([])
                  .links([])
                  .size([width, height])
                  .charge(-4000 )
                  .gravity(0.2)
                  .distance(200)
                  .friction(0.4)

        zoomed = =>
          return if @translateLock
          @workspace.attr "transform",
            "translate(#{d3.event.translate}) scale(#{d3.event.scale})"
        @zoom = d3.behavior.zoom().on('zoom', zoomed)

        # ignore panning and zooming when dragging node
        @translateLock = false
        # store the current zoom to undo changes from dragging a node
        currentZoom = undefined
        @force.drag()
        .on "dragstart", (d) ->
          that.translateLock = true
          currentZoom = that.zoom.translate()
          d3.select(this).classed("fixed", d.fixed = true)
        .on "dragend", (node) =>
          @trigger "node:dragend", node
          @zoom.translate currentZoom
          @translateLock = false

        @svg = d3.select(@el).append("svg:svg")
                .attr("pointer-events", "all")
                .attr('width', width)
                .attr('height', height)
                .call(@zoom)
                .on("dblclick.zoom", null)

        @workspace = @svg.append("svg:g")
        @workspace.append("svg:g").classed("connection-container", true)
        @workspace.append("svg:g").classed("node-container", true)

        @connectionAdder = new ConnectionAdder
          model: @model
          attributes: {force: @force, svg: @svg, graphView: this}

        @trashBin = new TrashBin
          model: @model
          attributes: {graphView: this}

        @dataTooltip = new DataTooltip
          model: @model
          attributes: {graphView: this}

        @zoomButtons = new ZoomButtons
          attributes: {zoom: @zoom, workspace: @workspace}

      toggleSidebar: ->
        if @sidebarShown
          $('#sidebar').animate 'width': '0%'
          $('#graph').animate 'width': '100%'
        else
          $('#sidebar').animate 'width': '30%'
          $('#graph').animate 'width': '70%'
        @sidebarShown = !@sidebarShown

      update: ->
        that = this
        nodes = @model.nodes.models
        connections = @model.connections.models

        @force.nodes(nodes).links(_.pluck(connections,'attributes')).start()

        connection = d3.select(".connection-container")
          .selectAll(".connection")
          .data connections
        connectionEnter = connection.enter().append("line")
          .attr("class", "connection")

        # old elements
        node = d3.select(".node-container")
          .selectAll(".node")
          .data(nodes, (node) -> node.cid)

        # new elements
        nodeEnter = node.enter().append("g")
        nodeEnter.append("text")
          .attr("dy", "50px")
        nodeEnter.append("circle")
          .attr("r", 25)

        connectionEnter
        .on "click", (d) =>
          @model.selectConnection d
          
        nodeEnter
        .on "dblclick", (d) ->
          d3.select(this).classed("fixed", d.fixed = false)
        .on "click", (d) =>
          if (d3.event.defaultPrevented)
            return
          @model.selectNode d
        .on "contextmenu", (d) =>
          d3.event.preventDefault()
          @trigger 'node:right-click', d

        .on "mouseover", (node) =>
          if @creatingConnection then return
          @trigger "node:mouseover", node

          connectionsToHL = @model.connections.filter (c) ->
            (c.get('source').cid is node.cid) or (c.get('target').cid is node.cid)

          nodesToHL = _.flatten connectionsToHL.map (c) -> [c.get('source'), c.get('target')]
          nodesToHL.push node

          @model.highlightNodes(nodesToHL)
          @model.highlightConnections(connectionsToHL)
        .on "mouseout", (node) =>
          @trigger "node:mouseout", node

        # update old and new elements
        node.attr('class', 'node')
          .classed('dim', (d) -> d.get('dim'))
          .classed('selected', (d) -> d.get('selected'))
          .classed('fixed', (d) -> d.fixed)
          .call(@force.drag)
        node.select('text')
          .text((d) -> d.get('name'))

        connection.attr("class", "connection")
          .classed('dim', (d) -> d.get('dim'))
          .classed('selected', (d) -> d.get('selected'))

        # delete unmatching elements
        node.exit().remove()
        connection.exit().remove()

        tick = =>
          connection
            .attr("x1", (d) -> d.attributes.source.x)
            .attr("y1", (d) -> d.attributes.source.y)
            .attr("x2", (d) -> d.attributes.target.x)
            .attr("y2", (d) -> d.attributes.target.y)
          node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
          @connectionAdder.tick()
        @force.on "tick", tick

      isContainedIn: (node, element) ->
        node.x < element.offset().left + element.width() &&
          node.x > element.offset().left &&
          node.y > element.offset().top &&
          node.y < element.offset().top + element.height()
