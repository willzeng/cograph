define ['jquery', 'underscore', 'backbone', 'd3'],
  ($, _, Backbone, d3) ->
    class ConnectionAdder extends Backbone.View
      el: $ '#graph'

      initialize: ->
        that = this
        @force = @attributes.force
        @svg = @attributes.svg
        @graphView = @attributes.graphView

        @svg.append("defs").append("marker")
            .attr("id", "draghead")
            .attr("viewBox", "0 -5 10 10")
            .attr("refX", 5)
            .attr("refY", 0)
            .attr("markerWidth", 3)
            .attr("markerHeight", 3)
            .attr("orient", "auto")
            .attr("fill", "black")
            .append("path")
              .attr("d", "M0,-5L10,0L0,5")

        @drag_line = @svg.append('svg:line')
                      .attr('class', 'dragline hidden')
                      .attr('x1', '0')
                      .attr('y1', '0')
                      .attr('x2', '50')
                      .attr('y2', '50')
                      .attr("marker-end", "url(#draghead)")
                      .data([{anchor:{x:0,y:0}}])
        @creatingConnection = false

        @svg.on "mousemove", () ->
          that.drag_line.attr('x2', d3.mouse(this)[0]).attr('y2', d3.mouse(this)[1])

        @graphView.on 'node:right-click', (node) =>
          if @creatingConnection
            @graphView.translateLock = false
            @drag_line.attr('class', 'dragline hidden')
            @model.selectConnection @model.putConnection "links to", @drag_line.data()[0].anchor, node
          else
            @graphView.translateLock = true
            @drag_line.attr('class', 'dragline')
              .data [{anchor:node}]
          @creatingConnection = !@creatingConnection

      tick: =>
        @drag_line
          .attr("x1", (d) => d.anchor.x+@graphView.zoom.translate()[0])
          .attr("y1", (d) => d.anchor.y+@graphView.zoom.translate()[1])
