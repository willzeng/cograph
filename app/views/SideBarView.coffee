define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class SideBarView extends Backbone.View
      el: $ 'body'
      name: ""
      type: "left"
      size: 150

      initialize: ->
        @name = if @attributes? then "-"+@attributes.name else ""
        @type = if @attributes? then @attributes.type else "left"
        @size = if @attributes? then @attributes.size else 150
        $('#sidebar-toggle'+@name).on 'click', @toggleSidebar
        @sidebarShown = false

      openSidebar: (nc) =>
        if nc.get('selected')
          if !@sidebarShown then @toggleSidebar()

      toggleSidebar: =>
        if @sidebarShown
          $('#sidebar'+@name).animate 'width': '0%'
          if @type is "right" then $('#graph').animate 'width': '100%'
        else
          $('#sidebar'+@name).animate 'width': @size+'px'
          if @type is "right" then $('#graph').animate 'width': ($('#graph').width()-@size)+"px"
        $('#sidebar-toggle'+@name).toggleClass('active')
        @sidebarShown = !@sidebarShown
