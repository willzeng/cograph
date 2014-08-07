define ['jquery', 'underscore', 'backbone', 'd3', 'text!templates/d3_defs.html'
  'cs!views/ConnectionAdder', 'cs!views/TrashBin', 'cs!views/DataTooltip', 'cs!views/ZoomButtons', 'text!templates/data_tooltip.html', 'text!templates/node-title.html'],
  ($, _, Backbone, d3, defs, ConnectionAdder, TrashBin, DataTooltip, ZoomButtons, popover, nodeTitle) ->
    class GraphView extends Backbone.View
      el: $ '#graph'

      events:
        "contextmenu": "rightClicked"

      # Parameters for display
      maxConnTextLength: 20
      maxNodeBoxHeight: 100
      nodeBoxWidth: 120
      maxInfoBoxHeight: 200
      infoBoxWidth: 120

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
          that.trigger "node:drag", d, d3.event
        .on "dragend", (node) =>
          @trigger "node:dragend", node, d3.event
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

      updateDetails: (incoming) ->
        if incoming?
          # don't updateDetails if we have only dimmed the one node
          if incoming.hasChanged('dim') and incoming.changedAttributes.length then return
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
            @model.trigger "conn:clicked", d
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
          .attr('height', @maxInfoBoxHeight)
          .attr('width', @infoBoxWidth)
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
          .text((d) =>
            if(d.get("name").length < @maxConnTextLength)
              return d.get("name")
            else 
              return d.get("name").substring(0,@maxConnTextLength-3)+"..."
        )
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
        nodeText = nodeEnter.append("foreignObject")
          .attr("y", "5")
          .attr("height", @maxNodeBoxHeight) #max height overflow is cut off
          .attr("width", @nodeBoxWidth)
          .attr("x", "-60")
          .attr('class', 'node-title')
        nodeInnerText = nodeText.append('xhtml:body')
            .attr('class', 'node-title-body')
        nodeEnter.append("foreignObject")
          .attr('y', '12')
          .attr('height', @maxInfoBoxHeight)
          .attr('width', @infoBoxWidth)
          .attr('x', '-21')
          .attr('class', 'node-info')
          .append('xhtml:body')
            .attr('class', 'node-info-body')

        nodeInnerText
          .on "dblclick", (d) ->
            d3.select(this).classed("fixed", d.fixed = false)
          .on "click", (d) =>
            # prevents node from being selected on drag
            if (d3.event.defaultPrevented) then return
            @model.select d
            @model.trigger "node:clicked", d
          .on "contextmenu", (node) ->
            d3.event.preventDefault()
            that.trigger('node:right-click', node, d3.event)
          .on "mouseenter", (node) =>
            @trigger "node:mouseenter", node
          .on "mouseout", (node) =>
            @trigger "node:mouseout", node
            node.fixed &= ~4 # unset the extra d3 fixed variable in the third bit of fixed

        # update old and new elements
        node.attr('id', (d) -> d.get('_id'))
        node.attr('class', 'node')
          .classed('dim', (d) -> d.get('dim'))
          .classed('selected', (d) -> d.get('selected'))
          .classed('fixed', (d) -> d.fixed & 1) # d3 preserves only first bit of fixed
          .call(@force.drag)
        node.select('.node-title-body')
          .html((d) -> _.template(nodeTitle, d))
          .style("background", (d) => @getColor d)
        node.select('.node-info-body')
          .html((d) -> _.template(popover, d))

        # move the popover info to align with the left of the text
        # construct the node boxes
        offsetV = 4
        offsetH = 12
        for t in node.select('.node-title')[0]
          el = $(t).find('.node-title-body')
          left = el.width()/2+parseInt(el.css('border-left-width'),10)
          top = el.height()/2+parseInt(el.css('border-bottom-width'),10)

          $(t)
            .attr('y', - top)

          info = $(t).parent().find('.node-info')
          info
            .attr('x',-left)
            .attr('y',top)

        # delete unmatching elements
        node.exit().remove()

        tick = =>
          connection.selectAll("line")
            .each((d, i) ->
              source = that.model.getSourceOf(d)
              target = that.model.getTargetOf(d)
              sx = source.x
              sy = source.y
              tx = target.x
              ty = target.y
              dy = ty - sy
              dx = tx - sx

              sh = $('#'+source.get('_id')).find('.node-title-body').height()/2
              th = $('#'+target.get('_id')).find('.node-title-body').height()/2
              
              su = (dy / dx) * (120 / 2)

              if(Math.abs(su) > sh)
                # case: intersects source node on top/bottom
                snu = (dx / dy) * (sh) #source relative x intercept
                #tu = (dx / dy) * (th) #wrong.

                if(ty < sy) #intersect source at top
                  scy = sy - sh
                  scx = sx - snu
                else #intersect source at bottom
                  scy = sy + sh
                  scx = sx + snu
              else
                #case: intersects source node on side
                snu = (dy / dx) * (120/2) #source relative y intercept

                if(tx < sx) #intersect source on the right
                  scx = sx - (120/2)
                  scy = sy - snu
                else 
                  scx = sx + (120/2)
                  scy = sy + snu
              
              if(Math.abs(su) > th)
                # case: intersects target at top/bottom
                snu = (dx / dy) * (th) #target relative x intercept

                if(sy < ty) #top
                  tcy = ty - th
                  tcx = tx - snu
                  
                else #bottom
                  tcy = ty + th
                  tcx = tx + snu
              else
                #case: intersects target node on side
                snu = (dy / dx) * (120/2) #target relative y intercept

                if(sx < tx) #intersect target on the right
                  tcx = tx - (120/2)
                  tcy = ty - snu
                else #target on left
                  tcx = tx + (120/2)
                  tcy = ty + snu

              d3.select(this).attr('x1', scx)
              d3.select(this).attr('y1', scy)
              d3.select(this).attr('x2', tcx)
              d3.select(this).attr('y2', tcy)
            )
           
          connection.select(".connection-text")
            .attr("transform", (d) => "translate(#{(@model.getSourceOf(d).x-@model.getTargetOf(d).x)/2+@model.getTargetOf(d).x},#{(@model.getSourceOf(d).y-@model.getTargetOf(d).y)/2+@model.getTargetOf(d).y})")
          node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
          @connectionAdder.tick
        @force.on "tick", tick

      rightClicked: (e) ->
        e.preventDefault()

      isContainedIn: (node, element) =>
        node.x < element.offset().left + element.outerWidth() &&
        node.x > element.offset().left &&
        node.y > element.offset().top &&
        node.y < element.offset().top + element.outerHeight()

      getColor: (nc) ->
          @model.defaultColors[nc.get('color')]

      
