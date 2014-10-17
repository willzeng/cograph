define ['jquery', 'underscore', 'backbone', 'd3', 'cs!views/svgDefs'
  'cs!views/ConnectionAdder', 'cs!views/TrashBin', 'cs!views/DataTooltip', 'cs!views/ZoomButtons', 
  'text!templates/data_tooltip.html', 'text!templates/node-title.html', 'linkify'],
  ($, _, Backbone, d3, svgDefs, ConnectionAdder, TrashBin, DataTooltip, ZoomButtons, popover, nodeTitle, linkify) ->
    class GraphView extends Backbone.View
      el: $ '#graph'

      events:
        "contextmenu": "rightClicked"
        "click #grid-view-button": "gridView"
        "click #graph-view-button": "resetPositions"

      # Parameters for display
      maxConnTextLength: 20
      maxNodeBoxHeight: 100 #4 lines
      nodeBoxWidth: 200
      maxInfoBoxHeight: 250
      infoBoxWidth: 200

      initialize: ->
        that = this
        @drawing = true
        @model.on 'init', @backgroundRender, this
        @model.nodes.on 'add remove', @updateForceGraph, this
        @model.connections.on 'add remove', @updateForceGraph, this
        @model.nodes.on 'change', @updateDetails, this
        @model.connections.on 'change', @updateDetails, this

        @model.on 'found:node', @centerOn, this

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
          if !(@gridViewOn)
            d3.select(this).classed("fixed", d.fixed = true)
            that.trigger "node:drag", d, d3.event
        .on "dragend", (node) =>
          @trigger "node:dragend", node, d3.event
          @zoom.translate @currentZoom
          @translateLock = false
          @force.stop()

        @svg = d3.select(@el).append("svg:svg")
                .attr("pointer-events", "all")
                .attr('width', width)
                .attr('height', height)
                .call(@zoom)
                .on("dblclick.zoom", null)
        def = @svg.append('svg:defs')
        (new svgDefs).addDefs def, @model.defaultColors

        # GridView parameters
        @gridViewOn = false
        @updateForceFlag = false
        @grid = {}
        @grid.spacing = [20,20] # Horizontal and Vertical node spacing
        @grid.padding = [200,70] # Left and top padding of the grid as a whole respectively
        @grid.colYs = [] #top margin

        @workspace = @svg.append("svg:g")

        @workspace.append("svg:g").classed("connection-container", true)
        @workspace.append("svg:g").classed("node-container", true)

        @connectionAdder = new ConnectionAdder
          model: @model
          attributes: {force: @force, graphView: this}

        @trashBin = new TrashBin
          model: @model
          attributes: {graphView: this}

        @dataTooltip = new DataTooltip
          model: @model
          attributes: {graphView: this}

        @zoomButtons = new ZoomButtons
          attributes: {zoom: @zoom, workspace: @workspace}

      loadForce: ->
        nodes = @model.nodes.models
        connections = @model.connections.models
        _.each connections, (c) =>
          c.source = @model.getSourceOf c
          c.target = @model.getTargetOf c
        @force.nodes(nodes).links(connections).start()

      backgroundRender: ->
        @loadForce()
        n = @model.nodes.models.length*@model.nodes.models.length*@model.nodes.models.length+50

        @drawing = false
        for i in [0..n] by 1
          @force.tick()
        @force.stop()
        @drawing = true

        setTimeout () =>
          @updateDetails()
          @force.tick()
        , 10

      updateForceGraph: ->
        if @gridViewOn
          @updateForceFlag = true # this flag stores if we will later need to reupdate the force graph
          @gridView {duration:0}
        else
          @loadForce()
          @updateDetails()
          setTimeout () =>
            @force.stop()
          , 1500

      updateDetails: (incoming) ->
        that = this

        if incoming?
          ignoredList = ['dim','id','_id']
          changedAttrs = (k for k,v of incoming.changed)
          if (_.difference changedAttrs, ignoredList).length is 0 then return
        that = this
        nodes = @model.nodes.models
        connections = @model.connections.models
        if @gridViewOn then connections = []

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
            if(!$(d3.event.toElement).closest('.connection').length)
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
          .attr('y', '1')
          .attr('height', @maxInfoBoxHeight)
          .attr('width', @infoBoxWidth)
          .attr('x', '-12')
          .attr('class', 'connection-info')
          .append('xhtml:body')
            .attr('class', 'connection-info-body')

        # old and new elements
        connection.attr("class", "connection")
          .classed('dim', (d) -> d.get('dim'))
          .each (d,i) ->
            line = d3.select(this).select("line.visible-line")
            if !d.get('selected')
              line.style("stroke", (d) -> that.getColor d)
            else 
              line.style("stroke", that.model.selectedColor)
            
            if d.get('color')
              line.attr("marker-end", "url(#arrowhead-"+d.get('color')+")")
            else 
              line.attr("marker-end", "url(#arrowhead)")
            if d.get('selected')
              line.attr("marker-end", "url(#arrowhead-selected)")
          .classed('selected', (d) -> d.get('selected'))
          
            
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
          .attr('data-nodeid', (d) -> d.get('_id'))
        nodeRectangle = nodeEnter.append('rect')
          .attr('x', '-80')
          .attr('y', '-15')
          .attr('width', '20')
          .attr('height', '30')
          .attr('fill', 'transparent')
        nodeText = nodeEnter.append("foreignObject")
          .attr("y", "5")
          .attr("height", @maxNodeBoxHeight) #max height overflow is cut off
          .attr("width", @nodeBoxWidth)
          .attr("x", -@nodeBoxWidth/2)
          .attr('class', 'node-title')
        nodeInnerText = nodeText.append('xhtml:body')
          .attr('class', 'node-title-body')
        nodeConnector = nodeEnter.append("circle")
          .attr('r', '5')
          .attr('cx', -@nodeBoxWidth/2-10)
          .attr('cy', '0')
          .attr('class', 'node-connector')
          .attr('fill', '#222') 
        nodeInfoText = nodeEnter.append("foreignObject")
          .attr('y', '12')
          .attr('height', @maxInfoBoxHeight)
          .attr('width', @infoBoxWidth)
          .attr('x', '-21')
          .attr('class', 'node-info')
          .append('xhtml:body')
            .attr('class', 'node-info-body')
        
        nodeRectangle
          .on "click", (d) =>
            @model.trigger "node:clicked", d
        nodeConnector
          .on "click", (d) =>
            @model.trigger "node:clicked", d
        nodeInnerText 
          .on "click", (d) =>
            @model.trigger "node:clicked", d
        node
          .on "dblclick", (d) ->
            that.model.select d
            that.model.trigger "node:dblclicked", d
          .on "contextmenu", (node) ->
            d3.event.preventDefault()
            that.trigger('node:right-click', node, d3.event)
          .on "mouseenter", (node) =>
            @trigger "node:mouseenter", node
          .on "mouseout", (node) =>
            # perhaps setting the foreignobject height dynamically would be better.
            if(!$(d3.event.toElement).closest('.node').length)
              @trigger "node:mouseout", node
            node.fixed &= ~4 # unset the extra d3 fixed variable in the third bit of fixed

        # update old and new elements
        node.attr('class', 'node')
          .classed('dim', (d) -> d.get('dim'))
          .classed('selected', (d) -> d.get('selected'))
          .classed('fixed', (d) -> d.fixed & 1) # d3 preserves only first bit of fixed
          .call(@force.drag)
          
        node.select('.node-title-body')
          .html((d) -> _.template(nodeTitle, d))
        node.select('.node-connector')
          .style("fill", (d) => @getColor d)
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

        # set-up clickable tags
        $('.tag-link').on "click", (e) =>
          e.preventDefault()
          tag = $(e.currentTarget).attr('data-tag')
          @trigger 'tag:click', tag

        tick = =>
          connection.selectAll("line")
            .attr("x1", (d) => @model.getSourceOf(d).x-(@nodeBoxWidth/2+10))
            .attr("y1", (d) => @model.getSourceOf(d).y)
            .attr("x2", (d) => @model.getTargetOf(d).x-(@nodeBoxWidth/2+10))
            .attr("y2", (d) => @model.getTargetOf(d).y)
          connection.select(".connection-text")
            .attr("transform", (d) => "translate(#{((@model.getSourceOf(d).x-@model.getTargetOf(d).x)/2+@model.getTargetOf(d).x)-(@nodeBoxWidth/2+10)},#{(@model.getSourceOf(d).y-@model.getTargetOf(d).y)/2+@model.getTargetOf(d).y})")
          node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
          @connectionAdder.tick

        if @gridViewOn
          $('.node-title-body').addClass('shown')
          $('.node-info-body').addClass('hide-toolbar')
          $('.node-info-body').addClass('shown').linkify()
        else
          $('.node-info-body').removeClass('hide-toolbar')
          tick()
        @force.on "tick", () =>
          if @drawing and !(@gridViewOn) then tick()

      gridView: (options) -> #trigger grid view
        if(!@gridViewOn)
          @gridViewOn = true  
          @model.dehighlight()
          @force.stop()

          # ignore connection events
          @model.connections.off 'add remove', @updateForceGraph
          @model.connections.off 'change', @updateDetails

          # Place nodes in a grid
          transitionDuration = if options.duration? then options.duration else 900
          columnNum = 1+Math.floor($(window).width()-@grid.padding[0])/(@nodeBoxWidth + @grid.spacing[0])
          theNodes = d3.select(".node-container").selectAll(".node")
          @zoom.scale(1).translate([@grid.padding[0],@grid.padding[1]])
          @workspace.transition().ease("linear").attr "transform", "translate(#{[@grid.padding[0],@grid.padding[1]]}) scale(1)"

          theNodes.transition()
            .duration(transitionDuration)
            .attr "transform", (d, i) =>
              pos = @placeInGrid d, i
              "translate(#{pos.x},#{pos.y})"
          @updateDetails()
      resetPositions: -> #reset back to graphView
        if @gridViewOn
          @grid.colYs.splice(0)
          @gridViewOn = false

          # reinitialize listening to connections
          @model.connections.on 'add remove', @updateForceGraph, this
          @model.connections.on 'change', @updateDetails, this

          theNodes = d3.select(".node-container").selectAll(".node")
          resetDuration = 900
          theNodes.transition()
            .duration(resetDuration)
            .attr "transform", (d, i) =>
              @placeInGrid d, i
              "translate(#{d.x},#{d.y})"
          @grid.colYs.splice(0)
          @dataTooltip.emptyTooltip()

          # if we need to update the force graph then start the force
          if @updateForceFlag then @force.start()
          @updateForceFlag = false

          setTimeout =>
            @updateDetails()
          , resetDuration

      placeInGrid: (d, i) ->
        columnTotal = 1 + Math.floor(($(window).width() - @grid.padding[0]) / (@nodeBoxWidth + @grid.spacing[0]))
        columnNum = (i%columnTotal)

        # calculate height of opened current node being positioned
        domEl = $('[data-nodeid="'+d.get('_id')+'"]').eq(0)
        domElHeight = Math.min(@maxInfoBoxHeight, domEl.find('.node-info-body').height()) + Math.min(@maxNodeBoxHeight, domEl.find('.node-title-body').height())
        begin = @grid.colYs[columnNum] || 0
        gridX = columnNum*(@nodeBoxWidth+@grid.spacing[0])+@grid.spacing[0]
        tempY = begin + @grid.spacing[1]
        @grid.colYs[columnNum] = tempY+domElHeight
        # if the node has no force graph pos then give it a grid pos
        if !(d.x) then d.x = gridX
        if !(d.y) then d.y = tempY
        {x:gridX, y:tempY}

      rightClicked: (e) ->
        e.preventDefault()
        @connectionAdder.clearDragLine()

      isContainedIn: (node, element) =>
        node.x < element.offset().left + element.outerWidth() &&
        node.x > element.offset().left &&
        node.y > element.offset().top &&
        node.y < element.offset().top + element.outerHeight()

      centerOn: (node) =>
        if @gridViewOn
          sortedCIds = (n.cid for n in @model.nodes.models).sort()
          i = sortedCIds.indexOf node.cid
          pos = @placeInGrid node, i
          translateParams = [$(window).width()/2-pos.x*@zoom.scale(),$(window).height()/2-pos.y*@zoom.scale()]
        else
          translateParams = [$(window).width()/2-node.x*@zoom.scale(),$(window).height()/2-node.y*@zoom.scale()]
        #update translate values
        @zoom.translate([translateParams[0], translateParams[1]])
        #translate workspace
        @workspace.transition().ease("linear").attr "transform", "translate(#{translateParams}) scale(#{@zoom.scale()})"

      getColor: (nc) ->
        @model.defaultColors[nc.get('color')]

