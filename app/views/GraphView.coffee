define ['jquery', 'underscore', 'backbone', 'd3', 'text!templates/node.html',
  'text!templates/node_circle.html'],
  ($, _, Backbone, d3, nodeTemplate, nodeCircleTemplate) ->
    class GraphView extends Backbone.View

      el: $ '#main-area'
      graph: $ '#graph'

      initialize: ->
        @model.nodes.on 'add', @update, this

      render: ->
        width = 600
        height = 300
        @force = d3.layout.force()
                  .nodes([])
                  .links([])
                  .size([width, height])
                  .charge(-500)
                  .gravity(0.5)

        zoomed = ->
          workspace.attr "transform",
            "translate(#{d3.event.translate}) scale(#{d3.event.scale})"
        zoom = d3.behavior.zoom().on('zoom', zoomed)

        svg = d3.select(@el).append("svg:svg")
                .attr("pointer-events", "all")
                .attr('width', width)
                .attr('height', height)
                .call(zoom)

        workspace = svg.append("svg:g")
        workspace.append("svg:g").classed("connection-container", true)
        workspace.append("svg:g").classed("node-container", true)

      update: ->
        nodes = @model.nodes.models
        if nodes.length > 1
          connections = [{source:0, target:1, name:"links"}]
        else
          connections = {}

        @force.nodes(nodes).links(connections).start()

        connection = d3.select(@el)
          .select(".connection-container")
          .selectAll(".connection")
          .data connections, (connection) -> connection.name
        connectionEnter = connection.enter().append("line")
          .attr("class", "connection")
          .attr("stroke", "grey")
          .attr("stroke-width", "8px")

        node = d3.select(@el)
          .select(".node-container")
          .selectAll(".node")
          .data(nodes, (node) -> node.get('name'))
        nodeEnter = node.enter()
          .append("g")
          .attr("class", "node")
        nodeEnter.append("text")
          .attr("dy", "20px")
          .text((d) -> d.get('name'))
        nodeEnter.append("circle")
          .attr("r", 5)

        tick = ->
          connection.attr("x1", (d) ->
            d.source.x
          ).attr("y1", (d) ->
            d.source.y
          ).attr("x2", (d) ->
            d.target.x
          ).attr("y2", (d) ->
            d.target.y
          )
          node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
        @force.on "tick", tick
