define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class TrashBin extends Backbone.View
      el: $ '#graph'

      initialize: ->
        @graphView = @attributes.graphView

        @graphView.on "node:drag", (node) =>
          if @graphView.isContainedIn node, $('#trash-bin')
            $("#trash-bin").addClass('selected')
          else
            $("#trash-bin").removeClass('selected')

        @graphView.on "node:dragend", (node) =>
          if @graphView.isContainedIn node, $('#trash-bin')
            @model.deSelect node
            spokes = @model.connections.filter (c) ->
              (c.get('source').cid is node.cid) or (c.get('target').cid is node.cid)
            @model.deSelect spoke for spoke in spokes
            @model.removeNode node
            $("#trash-bin").removeClass('selected')
