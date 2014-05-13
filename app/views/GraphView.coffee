define ['jquery', 'underscore', 'backbone', 'd3', 'text!templates/data_tooltip.html'],
  ($, _, Backbone, d3, dataTooltipTemplate) ->
    class GraphView extends Backbone.View
      el: $ '#graph'

      events:
        'click #sidebar-toggle': 'toggleSidebar'
        'click #zoom-in-button': 'scaleZoom'
        'click #zoom-out-button': 'scaleZoom'
        'mousemove svg' : 'trackCursor'

      initialize: ->
        that = this
        @model.nodes.on 'add change remove', @update, this
        @model.nodes.on 'remove', @emptyTooltip, this
        @model.connections.on 'add change remove', @update, this

        @dataToolTipShown = @sidebarShown = false
        @translateLock = @isHoveringANode = false

        width = $(@el).width()
        height = $(@el).height()

        @force = d3.layout.force()
                  .nodes([])
                  .links([])
                  .size([width, height])
                  .charge(-4000 )
                  .gravity(0.2)
                  .friction(0.6)

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
        .on "drag", (d)=>
          if @isContainedIn d, $('#trash-bin')
            $("#trash-bin").addClass('selected')
          else
            $("#trash-bin").removeClass('selected')
        .on "dragend", (node) =>
          if @isContainedIn node, $('#trash-bin')
            @model.removeNode node
            $.each(@model.connections.models, (i, model) =>
              if model.attributes.source.cid == node.cid || model.attributes.target.cid == node.cid
                @model.removeConnection model
            )
          @zoom.translate currentZoom
          @translateLock = false

        @svg = d3.select(@el).append("svg:svg")
                .attr("pointer-events", "all")
                .attr('width', width)
                .attr('height', height)
                .call(@zoom)
                .on("dblclick.zoom", null)

        #Per-type markers, as they dont inherit styles.
        @svg.append("defs").append("marker")
            .attr("id", "arrowhead")
            .attr("viewBox", "0 -5 10 10")
            .attr("refX", 16)
            .attr("refY", 0)
            .attr("markerWidth", 3)
            .attr("markerHeight", 3)
            .attr("orient", "auto")
            .attr("fill", "gray")
            .attr("stroke","white")
            .attr("stroke-width","4px")
            .attr("stroke-location","outside")
            .append("path")
              .attr("d", "M0,-5L10,0L0,5")

        @workspace = @svg.append("svg:g")
        @workspace.append("svg:g").classed("connection-container", true)
        @workspace.append("svg:g").classed("node-container", true)

        @drag_line = @svg.append('svg:line')
                      .attr('class', 'dragline hidden')
                      .attr('x1', '0')
                      .attr('y1', '0')
                      .attr('x2', '50')
                      .attr('y2', '50')
                      .data([{anchor:{x:0,y:0}}])
        @creatingConnection = false

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
          .attr("marker-end", "url(#arrowhead)")

        # old elements
        node = d3.select(".node-container")
          .selectAll(".node")
          .data(nodes, (node) -> node.cid)

        # new elements
        nodeEnter = node.enter().append("g")
        nodeEnter.append("text")
          .attr("dy", "40px")
        nodeEnter.append("circle")
          .attr("r", 25)

        connectionEnter
        .on "click", (d) =>
          @model.selectConnection d
        .on "mouseover", (datum, index)  =>
          if !@dataToolTipShown
            @isHoveringANode = setTimeout( () =>
              @dataToolTipShown = true
              $(".data-tooltip-container")
                .append _.template(dataTooltipTemplate, datum)
            ,200)
        .on "mouseout", (datum, index) =>
          window.clearTimeout(@isHoveringANode)
          @dataToolTipShown = false
          $(".data-tooltip-container").empty()

        nodeEnter
        .on "dblclick", (d) ->
          d3.select(this).classed("fixed", d.fixed = false)
        .on "click", (d) =>
          if (d3.event.defaultPrevented)
            return
          @model.selectNode d
        .on "contextmenu", (d) =>
          d3.event.preventDefault()
          $(".data-tooltip-container").empty()

          if @creatingConnection
            @translateLock = false
            @drag_line.attr('class', 'dragline hidden')
            @model.selectConnection @model.putConnection "links to", @drag_line.data()[0].anchor, d
          else
            @translateLock = true
            @drag_line.attr('class', 'dragline')
              .data [{anchor:d}]
          @creatingConnection = !@creatingConnection
        .on "mouseover", (datum, index) =>
          if @creatingConnection then return
          if !@dataToolTipShown
            @isHoveringANode = setTimeout( () =>
              @dataToolTipShown = true
              $(".data-tooltip-container")
                .append _.template(dataTooltipTemplate, datum)
            ,200)

          connectionsToHL = @model.connections.filter (c) ->
            (c.get('source').cid is datum.cid) or (c.get('target').cid is datum.cid)

          nodesToHL = _.flatten connectionsToHL.map (c) -> [c.get('source'), c.get('target')]
          nodesToHL.push datum

          @model.highlightNodes(nodesToHL)
          @model.highlightConnections(connectionsToHL)
        .on "mouseout", (datum, index) =>
          window.clearTimeout(@isHoveringANode)
          if !@translateLock
            @model.dehighlightConnections()
            @model.dehighlightNodes()
            @dataToolTipShown = false
            $(".data-tooltip-container").empty()

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

        @svg.on "mousemove", () ->
          that.drag_line.attr('x2', d3.mouse(this)[0]).attr('y2', d3.mouse(this)[1])

        tick = =>
          connection
            .attr("x1", (d) -> d.attributes.source.x)
            .attr("y1", (d) -> d.attributes.source.y)
            .attr("x2", (d) -> d.attributes.target.x)
            .attr("y2", (d) -> d.attributes.target.y)
          node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
          @drag_line
            .attr("x1", (d) -> d.anchor.x)
            .attr("y1", (d) -> d.anchor.y)
        @force.on "tick", tick

      scaleZoom: (event) ->
        if $(event.currentTarget).attr('id') is 'zoom-in-button'
          scale = 1.3
        else if $(event.currentTarget).attr('id') is 'zoom-out-button'
          scale = 1/1.3
        else
          scale = 1

        #find the current view and viewport settings
        center = [$(@el).width()/2, $(@el).height()/2]
        translate = @zoom.translate()
        view = {x: translate[0], y: translate[1]}

        #set the new scale factor
        newScale = @zoom.scale()*scale

        #calculate offset to zoom in center
        translate_orig = [(center[0] - view.x) / @zoom.scale(), (center[1] - view.y) / @zoom.scale()]
        diff = [translate_orig[0] * newScale + view.x, translate_orig[1] * newScale + view.y]
        view.x += center[0] - diff[0]
        view.y += center[1] - diff[1]

        #update zoom values
        @zoom.translate([view.x,view.y])
        @zoom.scale(newScale)

        #translate workspace
        @workspace.transition().ease("linear").attr "transform", "translate(#{[view.x,view.y]}) scale(#{newScale})"

      isContainedIn: (node, element) ->
        node.x < element.offset().left + element.width() &&
          node.x > element.offset().left &&
          node.y > element.offset().top &&
          node.y < element.offset().top + element.height()

      trackCursor: (event) ->
        $(".data-tooltip-container")
              .css('left',event.clientX)
              .css('top',event.clientY-20)

      emptyTooltip: ->
        @dataToolTipShown = false
        $(".data-tooltip-container").empty()
