define ['jquery', 'underscore', 'backbone', 'socket-io'],
  ($, _, Backbone, io) ->
    class TrashBin extends Backbone.View
      el: $ '#graph'
      socket: io.connect("")

      events:
        'click #show-all': 'bringBackAll'
        'click #hide-all': 'hideAll'

      initialize: ->
        @trashBin = $('#trash-bin')
        @graphView = @attributes.graphView
        @enteredWhileDragging = false

        @trashBin.on "mouseover", (e) =>
          if(!@trashBin.hasClass('dragging') && !@enteredWhileDragging)
            @trashBin.addClass('hover')

        @trashBin.on "mouseenter", (e) => 
          if(@trashBin.hasClass('dragging'))
            @enteredWhileDragging = true

        @trashBin.on "mouseleave", (e) =>
          @trashBin.removeClass('hover')
          @enteredWhileDragging = false

        @graphView.on "node:drag", (node, e) =>
          if @graphView.isContainedIn e.sourceEvent, @trashBin
            @trashBin.addClass('selected')
          else
            @trashBin.removeClass('selected')
          @trashBin.addClass('dragging')

        @graphView.on "node:dragend", (node, e) =>
          @trashBin.removeClass('dragging')
          if @graphView.isContainedIn e.sourceEvent, @trashBin
            @model.deSelect node
            spokes = @model.connections.filter (c) ->
              (c.get('source') is node.get('_id')) or (c.get('target') is node.get('_id'))
            @model.deSelect spoke for spoke in spokes
            @model.removeNode node
            @trashBin.removeClass('selected')

        @model.nodes.on 'add remove', @calcNumNodesHidden, this
        @model.on 'init saved:node', @calcNumNodesHidden, this
        @socket.on "/nodes:delete", => @calcNumNodesHidden()
        @socket.on "/nodes:create", => @calcNumNodesHidden()

      calcNumNodesHidden: ->
        @model.getNodeNames (names) =>
          if(names.length == 0)
            $('#add-title').focus()
          if(names.length-@model.nodes.length >= 0)
            $('#number-hidden').text names.length-@model.nodes.length
          else
            $('#number-hidden').text 0

      # This works quickly by loading the clientside prefetched nodes
      # right away and then updating them
      bringBackAll: ->
        if window.prefetch.nodes then @model.nodes.set window.prefetch.nodes, {silent:true}
        @model.nodes.fetch()
        if window.prefetch.connections then @model.connections.set window.prefetch.connections, {silent:true}
        @model.connections.fetch()

        @model.trigger "init"

        @trashBin.removeClass('hover')
        @enteredWhileDragging = true

      hideAll: ->
        @model.connections.reset()
        @model.nodes.reset()
        @graphView.updateDetails()
        @calcNumNodesHidden()

        @trashBin.removeClass('hover')
        @enteredWhileDragging = true
