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
            @model.removeNode node
            _.each @model.connections.models, (model) =>
              if model.attributes.source.cid == node.cid || model.attributes.target.cid == node.cid
                @model.removeConnection model
            $("#trash-bin").removeClass('selected')
