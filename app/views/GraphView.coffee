define ['jquery', 'underscore', 'backbone', 'd3', 'text!templates/d3_defs.html'
  'cs!views/ConnectionAdder', 'cs!views/TrashBin', 'cs!views/DataTooltip', 'cs!views/ZoomButtons', 'text!templates/data_tooltip.html'],
  ($, _, Backbone, d3, defs, ConnectionAdder, TrashBin, DataTooltip, ZoomButtons, popover) ->
    class GraphView extends Backbone.View
      el: $ '#graph'

      initialize: ->
        that = this
        @model.nodes.on 'add remove', @updateForceGraph, this
        @model.connections.on 'add remove', @updateForceGraph, this
        @model.nodes.on 'change', @updateDetails, this
        @model.connections.on 'change', @updateDetails, this

        @translateLock = false

        width = $(@el).width()
        height = $(@el).height()

        @force = d3.layout.force()
                  .nodes([])
                  .links([])
                  .size([width, height])
                  .charge(-4000)
                  .gravity(0.2)
                  .friction(0.6)
                  .distance(200)

        zoomed = =>
          return if @translateLock
          @workspace.attr "transform",
            "translate(#{d3.event.translate}) scale(#{d3.event.scale})"
        @zoom = d3.behavior.zoom().on('zoom', zoomed)

        # store the current zoom to undo changes from dragging a node
        @currentZoom = undefined
        @force.drag()
        .on "dragstart", (d) ->
          that.translateLock = true
          that.currentZoom = that.zoom.translate()
        .on "drag", (d) ->
          d3.select(this).classed("fixed", d.fixed = true)
          that.trigger "node:drag", d
        .on "dragend", (node) =>
          @trigger "node:dragend", node
          @zoom.translate @currentZoom
          @translateLock = false

        @svg = d3.select(@el).append("svg:svg")
                .attr("pointer-events", "all")
                .attr('width', width)
                .attr('height', height)
                .call(@zoom)
                .on("dblclick.zoom", null)
        @svg.append('defs').html(defs)

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

      updateForceGraph: ->
        nodes = @model.nodes.models
        connections = @model.connections.models
        _.each connections, (c) =>
          c.source = @model.getSourceOf c
          c.target = @model.getTargetOf c
        @force.nodes(nodes).links(connections).start()
        @updateDetails()

      updateDetails: ->
        that = this
        nodes = @model.nodes.models
        connections = @model.connections.models
        # old elements
        connection = d3.select(".connection-container")
          .selectAll(".connection")
          .data(connections, (conn) -> conn.cid)

        # new elements
        connectionEnter = connection.enter().append("g")
          .attr("class", "connection")
          .on "click", (d) =>
            @model.select d
          .on "mouseover", (conn)  =>
            @trigger "connection:mouseover", conn
          .on "mouseout", (conn) =>
            @trigger "connection:mouseout", conn
        connectionEnter.append("line")
          .attr('class', 'select-zone')
        connectionEnter.append("line")
          .attr('class', 'visible-line')
          .attr("marker-end", "url(#arrowhead)")
          .style("stroke", (d) => @getColor d)
        text-group = connectionEnter.append("g")
          .attr('class', 'connection-text')
        text-group.append("text")
          .attr("text-anchor", "middle")
        text-group.append("foreignObject")
          .attr('y', '0')
          .attr('height', '200')
          .attr('width', '120')
          .attr('x', '-12')
          .attr('class', 'connection-info')
          .append('xhtml:body')
            .attr('class', 'connection-info-body')

        # old and new elements
        connection.attr("class", "connection")
          .classed('dim', (d) -> d.get('dim'))
          .classed('selected', (d) -> d.get('selected'))
          .each (d,i) ->
            line = d3.select(this).select("line.visible-line")
            line.style("stroke", (d) -> that.getColor d)
            if d.get('selected')
              line.attr("marker-end", "url(#arrowhead-selected)")
            else
              line.attr("marker-end", "url(#arrowhead)")
        connection.select("text")
          .text((d) -> d.get("name"))
        connection.select('.connection-info-body')
          .html((d) -> _.template(popover, d))

        # move the popover info to align with the left of the text
        for t in connection.select('text')[0]
          dim = t.getBBox()
          info = $(t).parent().find('.connection-info')
          info
            .attr('x',dim.x)

        # remove deleted elements
        connection.exit().remove()

        # old elements
        node = d3.select(".node-container")
          .selectAll(".node")
          .data(nodes, (node) -> node.cid)

        # new elements
        nodeEnter = node.enter().append("g")
        nodeEnter.append("line")
          .attr("class","select-zone")
        nodeEnter.append("line")
        nodeEnter.append("rect").style("fill", (d) => @getColor d)
        nodeEnter.append("text")
          .attr("dy", "5px")
        nodeEnter.append("foreignObject")
          .attr('y', '12')
          .attr('height', '200')
          .attr('width', '120')
          .attr('x', '-21')
          .attr('class', 'node-info')
          .append('xhtml:body')
            .attr('class', 'node-info-body')

        nodeEnter
          .on "dblclick", (d) ->
            d3.select(this).classed("fixed", d.fixed = false)
          .on "click", (d) =>
            # prevents node from being selected on drag
            if (d3.event.defaultPrevented) then return
            @model.select d
          .on "contextmenu", (node) ->
            d3.event.preventDefault()
            that.trigger('node:right-click', node, d3.event)
          .on "mouseover", (node) =>
            @trigger "node:mouseover", node
          .on "mouseout", (node) =>
            @trigger "node:mouseout", node
            node.fixed &= ~4 # unset the extra d3 fixed variable in the third bit of fixed

        # update old and new elements
        node.attr('class', 'node')
          .classed('dim', (d) -> d.get('dim'))
          .classed('selected', (d) -> d.get('selected'))
          .classed('fixed', (d) -> d.fixed & 1) # d3 preserves only first bit of fixed
          .call(@force.drag)
        node.select('text')
          .text((d) -> d.get('name'))
        node.select('rect')
          .style("fill", (d) => @getColor d)
        node.select('.node-info-body')
          .html((d) -> _.template(popover, d))

        # move the popover info to align with the left of the text
        # construct the node boxes
        offsetV = 4
        offsetH = 12
        for t in node.select('text')[0]
          dim = t.getBBox()
          info = $(t).parent().find('.node-info')
          info
            .attr('x',dim.x-(offsetH/2))
          line = $(t).parent().find('line')
          line
            .attr('x1', dim.x-(offsetH)/2)
            .attr('y1', dim.y+dim.height+2)
            .attr('x2', dim.x + dim.width+(offsetH)/2)
            .attr('y2', dim.y+dim.height+2)
            .attr('stroke', '#ccc')
            .attr('stroke-width', '4px')
          rect = $(t).parent().find('rect')
          rect
            .attr('width', dim.width+ offsetH)
            .attr('height', dim.height+ offsetV)
            .attr('x', dim.x - (offsetH/2))
            .attr('y', dim.y - (offsetV/2))

        # delete unmatching elements
        node.exit().remove()

        tick = =>
          connection.selectAll("line")
            .attr("x1", (d) => @model.getSourceOf(d).x)
            .attr("y1", (d) => @model.getSourceOf(d).y)
            .attr("x2", (d) => @model.getTargetOf(d).x)
            .attr("y2", (d) => @model.getTargetOf(d).y)
          connection.select(".connection-text")
            .attr("transform", (d) => "translate(#{(@model.getSourceOf(d).x-@model.getTargetOf(d).x)/2+@model.getTargetOf(d).x},#{(@model.getSourceOf(d).y-@model.getTargetOf(d).y)/2+@model.getTargetOf(d).y})")
          node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
          @connectionAdder.tick
        @force.on "tick", tick

      isContainedIn: (node, element) =>
        node.x+@currentZoom[0] < element.offset().left + element.width() &&
          node.x+@currentZoom[0] > element.offset().left &&
          node.y+@currentZoom[1] > element.offset().top &&
          node.y+@currentZoom[1] < element.offset().top + element.height()

      getColor: (nc) ->
          @model.defaultColors[nc.get('color')]
