define ['jquery', 'underscore', 'backbone', 'text!templates/details_box.html'],
  ($, _, Backbone, detailsTemplate) ->
    class DetailsView extends Backbone.View

      el: $ '#graph'
      viewBox: $ '#main-container'

      events:
        'click .node': 'update'
        'click #togglesidebar' : 'togglesidebar'

      update: (clickedDOM) ->
        $(".details-container").empty()

        clickedID = $(clickedDOM.currentTarget).data("node-id")
        clickedNode = @model.nodes.get(clickedID)

        $(".details-container").append _.template(detailsTemplate, clickedNode)

      togglesidebar: ->
        console.log('toggling sidebar');
        if($("#sidebar").hasClass("selected"))
          $("#sidebar").removeClass("selected")
        else
          $("#sidebar").addClass("selected")
        