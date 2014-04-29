define ['jquery', 'underscore', 'backbone', 'd3', 'text!templates/node.html',
  'text!templates/node_circle.html'],
  ($, _, Backbone, d3, nodeTemplate, nodeCircleTemplate) ->
    class GraphView extends Backbone.View

      el: $ '#main-area'
      graph: $ '#graph'

      initialize: ->
        @model.nodes.on 'add', @update, this

      # update: (node) ->
      #   $(@el).append _.template(nodeTemplate, node.attributes)
      #   nodeCircle = $ _.template(nodeCircleTemplate, node)
      #   $(@graph).append nodeCircle

      render: ->
        initialWindowWidth = @$el.width()
        initialWindowHeight = @$el.height()
        @force = d3.layout.force()
          .size([initialWindowWidth, initialWindowHeight])
          .charge(-500)
          .gravity(0.2)

        svg = d3.select(@el).append("svg:svg").attr("pointer-events", "all")
        zoom = d3.behavior.zoom()

        # create arrowhead definitions
        defs = svg.append("defs")

        defs
          .append("marker")
          .attr("id", "Triangle")
          .attr("viewBox", "0 0 20 15")
          .attr("refX", "15")
          .attr("refY", "5")
          .attr("markerUnits", "userSpaceOnUse")
          .attr("markerWidth", "20")
          .attr("markerHeight", "15")
          .attr("orient", "auto")
          .append("path")
            .attr("d", "M 0 0 L 10 5 L 0 10 z")

        defs
          .append("marker")
          .attr("id", "Triangle2")
          .attr("viewBox", "0 0 20 15")
          .attr("refX", "-5")
          .attr("refY", "5")
          .attr("markerUnits", "userSpaceOnUse")
          .attr("markerWidth", "20")
          .attr("markerHeight", "15")
          .attr("orient", "auto")
          .append("path")
            .attr("d", "M 10 0 L 0 5 L 10 10 z")

        # add standard styling
        style = $("
        <style>
          .nodeContainer .node text { opacity: 0.5; }
          .nodeContainer .selected circle { fill: steelblue; }
          .nodeContainer .node:hover text { opacity: 1; }
          .nodeContainer:hover { cursor: pointer; }
          .connectionContainer .link { stroke: gray; opacity: 0.5; }
        </style>
        ")
        $("html > head").append(style)

        # outermost wrapper - this is used to capture all zoom events
        zoomCapture = svg.append("g")

        # this is in the background to capture events not on any node
        # should be added first so appended nodes appear above this
        zoomCapture.append("svg:rect")
               .attr("width", "100%")
               .attr("height", "100%")
               .style("fill-opacity", "0%")

        # lock infrastracture to ignore zoom changes that would
        # typically occur when dragging a node
        translateLock = false
        currentZoom = undefined
        @force.drag().on "dragstart", ->
          translateLock = true
          currentZoom = zoom.translate()
        .on "dragend", ->
          zoom.translate currentZoom
          translateLock = false

        # add event listener to actually affect UI

        # ignore zoom event if it's due to a node being dragged

        # otherwise, translate and scale according to zoom
        zoomCapture.call(zoom.on("zoom", -> # ignore double click to zoom
          return  if translateLock
          workspace.attr "transform",
            "translate(#{d3.event.translate}) scale(#{d3.event.scale})"

        )).on("dblclick.zoom", null)

        # inner workspace which nodes and links go on
        # scaling and transforming are abstracted away from this
        workspace = zoomCapture.append("svg:g")

        # containers to house nodes and links
        # so that nodes always appear above links
        connectionContainer = workspace.append("svg:g").classed("connectionContainer", true)
        nodeContainer = workspace.append("svg:g").classed("nodeContainer", true)
        return this

      update: ->
        nodes = ({name:nModel.attributes.name} for nModel in @model.nodes.models)
        connections = {}
        #console.log nodes.models
        @force.nodes(nodes).links(connections).start()
        # connection = d3.select(@el)
        #   .select(".connectionContainer")
        #   .selectAll(".connection")
        #   .data connections, (connection) -> connection.source.text + connection.target.text
        # connectionEnter = connection.enter().append("line")
        #   .attr("class", "connection")
        #   .attr('marker-end', (connection) ->
        #     'url(#Triangle)' if connection.direction is 'forward' or\
        #        connection.direction is 'bidirectional')
        #   .attr('marker-start', (connection) ->
        #     'url(#Triangle2)' if connection.direction is 'backward' or\
        #        connection.direction is 'bidirectional')

        #@force.start()
        #connection.exit().remove()
        #connectionEnter.attr "stroke-width", (connection) -> 5 * connection.strength

        node = d3.select(@el)
          .select(".nodeContainer")
          .selectAll(".node")
          .data nodes, (node) -> node.name
        nodeEnter = node.enter()
          .append("g")
          .attr("class", "node")
          .call(@force.drag)
        nodeEnter.append("text")
            .attr("dy", "20px")
            .style("text-anchor", "middle")
            .text (d) -> d.name

        nodeEnter.append("circle")
             .attr("r", 5)
             .attr("cx", 0)
             .attr("cy", 0)

        node.exit().remove()
        @force.on "tick", ->
          # link.attr("x1", (d) ->
          #   d.source.x
          # ).attr("y1", (d) ->
          #   d.source.y
          # ).attr("x2", (d) ->
          #   d.target.x
          # ).attr("y2", (d) ->
          #   d.target.y
          # )
          node.attr "transform", (d) ->
            "translate(#{d.x},#{d.y})"

