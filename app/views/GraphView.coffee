define ['jquery', 'underscore', 'backbone', 'd3', 'text!templates/node.html',
  'text!templates/node_circle.html'],
  ($, _, Backbone, d3, nodeTemplate, nodeCircleTemplate) ->
    class GraphView extends Backbone.View

      el: $ '#graph'

      events:
        'click #sidebar-toggle': 'toggleSidebar'

      initialize: ->
        @model.nodes.on 'add', @update, this
        @model.nodes.on 'change', @update, this
        @model.connections.on 'add', @update, this

        @sidebarShown = false

        width = $(@el).width()
        height = $(@el).height()

        @force = d3.layout.force()
                  .nodes([])
                  .links([])
                  .size([width, height])
                  .charge(-5000)
                  .gravity(0.2)

        zoomed = ->
          return if translateLock
          workspace.attr "transform",
            "translate(#{d3.event.translate}) scale(#{d3.event.scale})"
        zoom = d3.behavior.zoom().on('zoom', zoomed)

        # ignore panning and zooming when dragging node
        translateLock = false
        # store the current zoom to undo changes from dragging a node
        currentZoom = undefined
        @force.drag().on "dragstart", ->
          translateLock = true
          currentZoom = zoom.translate()
        .on "dragend", ->
          zoom.translate currentZoom
          translateLock = false

        @svg = d3.select(@el).append("svg:svg")
                .attr("pointer-events", "all")
                .attr('width', width)
                .attr('height', height)
                .call(zoom)

        workspace = @svg.append("svg:g")
        workspace.append("svg:g").classed("connection-container", true)
        workspace.append("svg:g").classed("node-container", true)

        @drag_line = @svg.append('svg:line')
                      .attr('class', 'link dragline')
                      .attr('x1', '0')
                      .attr('y1', '0')
                      .attr('x2', '50')
                      .attr('y2', '50')

        @mousedown_node = {x:0,y:0}
        @creatingConnection = true

      toggleSidebar: ->
        if @sidebarShown
          $('#sidebar').animate 'width': '0%'
          $('#graph').animate 'width': '100%'
        else
          $('#sidebar').animate 'width': '30%'
          $('#graph').animate 'width': '70%'
        @sidebarShown = !@sidebarShown

      update: ->
        nodes = @model.nodes.models
        connections = (connection.attributes for connection in @model.connections.models)

        @force.nodes(nodes).links(connections).start()

        connection = d3.select(@el)
          .select(".connection-container")
          .selectAll(".connection")
          .data connections, (connection) -> connection.name
        connectionEnter = connection.enter().append("line")
          .attr("class", "connection")

        node = d3.select(@el)
          .select(".node-container")
          .selectAll(".node")
          .data(nodes, (node) -> node.cid)
          .attr("class", (d) -> if d.get('selected') then 'node selected' else 'node')
        nodeEnter = node.enter()
          .append("g")
          .attr("class", (d) -> if d.get('selected') then 'node selected' else 'node')
          # .call(@force.drag)
        nodeEnter.append("text")
          .attr("dy", "40px")
          .text((d) -> d.get('name'))
        nodeEnter.append("circle")
          .attr("r", 25)
        nodeEnter.on "click", (datum, index) =>
          @model.selectNode datum
          @trigger "node:click", datum

        nodeEnter.on "mousedown", (d) =>
          @creatingConnection = true
          @mousedown_node = {x:d.x,y:d.y}
          @drag_line.attr('x1', d.x).attr('y1', d.y)

        that = this
        @svg.on "mousemove", () ->
          that.drag_line.attr('x2', d3.mouse(this)[0]).attr('y2', d3.mouse(this)[1])

        tick = ->
          connection
            .attr("x1", (d) -> d.source.x)
            .attr("y1", (d) -> d.source.y)
            .attr("x2", (d) -> d.target.x)
            .attr("y2", (d) -> d.target.y)
          node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
        @force.on "tick", tick
