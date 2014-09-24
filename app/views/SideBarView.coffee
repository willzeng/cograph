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
          if @type is "right"
            $('#sidebar'+@name).animate 'width': '0%', 100, "linear"
            $('#page-container').animate 'right': '0%', 100, "linear"
            $('#page-container').animate 'width': $('#page-container').width() + @size, 100, "linear" 
          else
            $('#sidebar'+@name).animate 'width': '0%', 100, "linear"
            $('#page-container').animate 'left': '0%', 100, "linear"
            $('#page-container').animate 'width': $('#page-container').width() + @size, 100, "linear" 
        else  
          if @type is "right"
            $('#sidebar'+@name).animate 'width': @size+'px', 100, "linear"
            $('#page-container').animate 'right': @size+'px', 100, "linear"
            $('#page-container').animate 'width': $('#page-container').width() - @size, 100, "linear"
          else
            $('#sidebar'+@name).animate 'width': @size+'px', 100, "linear"
            $('#page-container').animate 'left': @size+'px', 100, "linear"
            $('#page-container').animate 'width': $('#page-container').width() - @size, 100, "linear"
        $('#sidebar-toggle'+@name).toggleClass('active')
        @sidebarShown = !@sidebarShown
