define ['jquery', 'underscore', 'backbone', 'd3', 'cs!models/ConnectionModel'],
  ($, _, Backbone, d3, ConnectionModel) ->
    class ConnectionAdder extends Backbone.View
      el: $ '#graph'

      events:
        'click .node-connect': 'createDragLine'

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

        @creatingConnection = false
        @model.on "node:clicked", (node) =>
          if @creatingConnection
            @makeConnection node
            @creatingConnection = !@creatingConnection

      makeConnection: (node) =>
        @drag_line.classed('hidden', true)
        if node != @drag_line.datum()
          connection = new ConnectionModel
            source: @drag_line.datum().get('_id')
            target: node.get('_id')
            _docId: @model.documentModel.get('_id')
          $.when(connection.save()).then =>
            newConn = @model.putConnection connection
            @model.select newConn
            @model.newConnectionCreated newConn

      createDragLine: (e) ->
        connectId = parseInt $(e.currentTarget).attr("data-id")
        node = @model.nodes.findWhere {_id:connectId}
        #origin is mouse position
        offset = $('svg').offset()
        @drag_line.classed('hidden', false)
          .datum(node)
          .attr("x1", (d) => e.pageX-offset.left)
          .attr("y1", (d) => e.pageY-offset.top)
        @creatingConnection = !@creatingConnection

      tick: =>
        @drag_line
          .attr("x1", (d) => d.x + @graphView.zoom.translate[0])
          .attr("y1", (d) => d.y + @graphView.zoom.translate[1])
