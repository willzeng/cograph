define ['jquery', 'underscore', 'backbone', 'd3', 'cs!models/ConnectionModel'],
  ($, _, Backbone, d3, ConnectionModel) ->
    class ConnectionAdder extends Backbone.View
      el: $ '#graph'

      initialize: ->
        that = this
        @force = @attributes.force
        @svg = @attributes.svg
        @graphView = @attributes.graphView

        @drag_line = @svg.append('svg:line')
                      .attr('class', 'dragline hidden')
                      .attr("marker-end", "url(#draghead)")
                      .data([{anchor:{x:0,y:0}}])
        @creatingConnection = false

        @svg.on "mousemove", () ->
          that.drag_line.attr('x2', d3.mouse(this)[0]).attr('y2', d3.mouse(this)[1])

        @graphView.on 'node:right-click', (node) =>
          if @creatingConnection
            @graphView.translateLock = false
            @drag_line.attr('class', 'dragline hidden')
            if node.cid != @drag_line.data()[0].anchor.cid
              connection = new ConnectionModel
                name: 'links to'
                source: @drag_line.data()[0].anchor
                target: node
              @model.selectConnection @model.putConnection connection
          else
            @graphView.translateLock = true
            @drag_line.attr('class', 'dragline')
              .data [{anchor:node}]
          @creatingConnection = !@creatingConnection

      tick: =>
        @drag_line
          .attr("x1", (d) => d.anchor.x+@graphView.zoom.translate()[0])
          .attr("y1", (d) => d.anchor.y+@graphView.zoom.translate()[1])
