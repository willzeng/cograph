define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class SideBarView extends Backbone.View
      el: $ '#graph'

      events:
        'click #sidebar-toggle': 'toggleSidebar'

      initialize: ->
        @sidebarShown = false
        @model.nodes.on "change:selected", @openSidebar, @model
        @model.connections.on "change:selected", @openSidebar, this

      openSidebar: (nc) =>
        if nc.get('selected')
          if !@sidebarShown then @toggleSidebar()

      toggleSidebar: ->
        if @sidebarShown
          $('#sidebar').animate 'width': '0%'
          $('#graph').animate 'width': '100%'
        else
          $('#sidebar').animate 'width': '25%'
          $('#graph').animate 'width': '75%'
        @sidebarShown = !@sidebarShown
