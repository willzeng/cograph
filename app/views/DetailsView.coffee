define ['jquery', 'underscore', 'backbone', 'text!templates/details_box.html'],
  ($, _, Backbone, detailsTemplate) ->
    class DetailsView extends Backbone.View

      el: $ '#graph'

      events:
        'click .close' : 'closeDetail'

      initialize: ->
        @model.nodes.on 'change', @update, this

      update: ->
        selectedNode = @model.nodes.findWhere {'selected':true}

        $("#details-container").empty()

        if selectedNode
          $("#details-container").append _.template(detailsTemplate, selectedNode)

      closeDetail: () ->
        $('#details-container').empty()
        # TODO deselect node
