define ['jquery', 'underscore', 'backbone', 'text!templates/details_box.html'],
  ($, _, Backbone, detailsTemplate) ->
    class DetailsView extends Backbone.View

      el: $ '#graph'
      viewBox: $ '#main-container'

      initialize: ->
        @model.on 'select:node', (datum) => 
          @update datum
      
      update: (clickedNode) ->
        $(".details-container").empty()

        $(".details-container").append _.template(detailsTemplate, clickedNode)
