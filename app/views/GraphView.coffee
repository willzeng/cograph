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
        @model.nodes.on 'add', @update, this
        @model.nodes.on 'change', @update, this
        @model.connections.on 'add', @update, this
        @dataToolTipShown = false
        @sidebarShown = false
        @translateLock = false
        @isHoveringANode = false

      toggleSidebar: ->
        if @sidebarShown
          $('#sidebar').animate 'width': '0%'
          $('#graph').animate 'width': '100%'
        else
          $('#sidebar').animate 'width': '30%'
          $('#graph').animate 'width': '70%'
        @sidebarShown = !@sidebarShown

      render: ->
        width = $(@el).width()
        height = $(@el).height()

        @force = d3.layout.force()
                  .nodes([])
                  .links([])
                  .size([width, height])
                  .charge(-5000)
                  .gravity(0.2)

        zoomed = =>
          return if @translateLock
          @workspace.attr "transform",
            "translate(#{d3.event.translate}) scale(#{d3.event.scale})"
        @zoom = d3.behavior.zoom().on('zoom', zoomed)

        # ignore panning and zooming when dragging node
        @translateLock = false
        # store the current zoom to undo changes from dragging a node
        currentZoom = undefined
        @force.drag().on "dragstart", =>
          @translateLock = true
          currentZoom = @zoom.translate()
        .on "dragend", =>
          @zoom.translate currentZoom
          @translateLock = false

        svg = d3.select(@el).append("svg:svg")
                .attr("pointer-events", "all")
                .attr('width', width)
                .attr('height', height)
                .call(@zoom)

        @workspace = svg.append("svg:g")
        @workspace.append("svg:g").classed("connection-container", true)
        @workspace.append("svg:g").classed("node-container", true)

      update: ->
        nodes = @model.nodes.models
        connections = (connection.attributes for connection in @model.connections.models)

        @force.nodes(nodes).links(connections).start()

        connection = d3.select(@el)
          .select(".connection-container")
          .selectAll(".connection")
          .data connections, (connection) -> connection.name
        connection.enter().append("line")
          .attr("class", "connection")

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
        nodeEnter.on "click", (datum, index) =>
          @model.selectNode datum
          @trigger "node:click", datum

        nodeEnter.on "mouseover", (datum, index) =>
          if(!@dataToolTipShown)
            @isHoveringANode=setTimeout(()=>
              @dataToolTipShown = true
              $(".data-tooltip-container")
                .append _.template(dataTooltipTemplate, datum)
            ,200)
          _.each(@model.connections.models, (c, i) =>
            if(c.attributes.source.cid == datum.cid)
              console.log _.findWhere(@model.nodes.models, {cid: c.attributes.target.cid})
          )
        nodeEnter.on "mouseout", (datum, index) =>
          window.clearTimeout(@isHoveringANode)
          if !@translateLock
            @dataToolTipShown = false
            $(".data-tooltip-container").empty()

        # update old and new elements
        node.attr("class", (d) -> if d.get('selected') then 'node selected' else 'node')
          .call(@force.drag)
        node.select('text')
          .text((d) -> d.get('name'))

        # delete unmatching elements
        node.exit().remove()

        tick = ->
          connection
            .attr("x1", (d) -> d.source.x)
            .attr("y1", (d) -> d.source.y)
            .attr("x2", (d) -> d.target.x)
            .attr("y2", (d) -> d.target.y)
          node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
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

      trackCursor: (event) ->
        $(".data-tooltip-container")
              .css('left',event.clientX)
              .css('top',event.clientY-20)
