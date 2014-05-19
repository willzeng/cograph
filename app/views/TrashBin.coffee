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
            $("#trash-bin").removeClass('selected')
