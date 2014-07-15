define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class TrashBin extends Backbone.View
      el: $ '#graph'
      that = this
      initialize: ->
        @graphView = @attributes.graphView

        @graphView.on "node:drag", (node, e) =>
          if @graphView.isContainedIn e.sourceEvent, $('#trash-bin')
            $("#trash-bin").addClass('selected')
          else
            $("#trash-bin").removeClass('selected')

        @graphView.on "node:dragend", (node, e) =>
          if @graphView.isContainedIn e.sourceEvent, $('#trash-bin')
            @model.deSelect node
            spokes = @model.connections.filter (c) ->
              (c.get('source') is node.get('_id')) or (c.get('target') is node.get('_id'))
            @model.deSelect spoke for spoke in spokes
            @model.removeNode node
            $("#trash-bin").removeClass('selected')
