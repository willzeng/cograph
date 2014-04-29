define ['jquery', 'underscore', 'backbone', 'text!templates/details_box.html'],
  ($, _, Backbone, detailsTemplate) ->
    class DetailsView extends Backbone.View

      el: $ '#graph'
      viewBox: $ '#main-area'

      events:
        'click .node': 'update'

      update: (clickedDOM) ->
        $(".details-container").empty()

        clickedID = $(clickedDOM.currentTarget).data("node-id")
        clickedNode = @model.nodes.get(clickedID)

        $(".details-container").append _.template(detailsTemplate, clickedNode)
