define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class SideBarView extends Backbone.View
      el: $ '#graph'

      events:
        'click #sidebar-toggle': 'toggleSidebar'
        'click .node': 'openSidebar'

      initialize: ->
        @sidebarShown = false

      openSidebar: ->
        if !@sidebarShown then @toggleSidebar()

      toggleSidebar: ->
        if @sidebarShown
          $('#sidebar').animate 'width': '0%'
          $('#graph').animate 'width': '100%'
        else
          $('#sidebar').animate 'width': '30%'
          $('#graph').animate 'width': '70%'
        @sidebarShown = !@sidebarShown
