define ['jquery', 'underscore', 'backbone', 'd3', 'cs!models/ConnectionModel'],
  ($, _, Backbone, d3, ConnectionModel) ->
    class ConnectionAdder extends Backbone.View
      el: $ '#graph'

      initialize: ->
        that = this
        @svg = @attributes.svg
        @graphView = @attributes.graphView

        @drag_line = @svg.append('svg:line')
                      .attr('class', 'dragline hidden')
                      .attr("marker-end", "url(#draghead)")
                      .datum(x:0, y:0)
        @creatingConnection = false

        @attributes.svg.on "mousemove", () ->
          that.drag_line.attr('x2', d3.mouse(this)[0]).attr('y2', d3.mouse(this)[1])

        @graphView.on 'node:right-click', (node) =>
          if @creatingConnection
            @drag_line.classed('hidden', true)
            if node != @drag_line.datum()
              connection = new ConnectionModel
                source: @drag_line.datum().get('_id')
                target: node.get('_id')
                _docId: @model.documentModel.get('_id')
              $.when(connection.save()).then =>
                @model.select @model.putConnection connection
                @model.newConnectionCreated()
          else
            @drag_line.classed('hidden', false)
              .datum(node)
              .attr("x1", (d) => d.x + @graphView.zoom.translate()[0])
              .attr("y1", (d) => d.y + @graphView.zoom.translate()[1])
          @creatingConnection = !@creatingConnection

      tick: =>
        @drag_line
          .attr("x1", (d) => d.x + @graphView.zoom.translate()[0])
          .attr("y1", (d) => d.y + @graphView.zoom.translate()[1])
