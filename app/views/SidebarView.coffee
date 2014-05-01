define ['jquery', 'underscore', 'backbone', 'd3'],
  ($, _, Backbone, d3) ->
    class SidebarView extends Backbone.View

      el: $ '#sidebar-container';   

      events:
        'click #sidebar-toggle': 'toggleSidebar'
      
      toggleSidebar: ->
        $('#sidebar').toggle()

