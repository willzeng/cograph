define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class TrashBin extends Backbone.View
      el: $ '#graph'

      events:
        'click #bring-all-nodes-to-view': 'bringBackAll'

      initialize: ->

        @graphView = @attributes.graphView

        @graphView.on "node:drag", (node, e) =>
          if @graphView.isContainedIn e.sourceEvent, $('#trash-bin')
            $("#trash-bin").addClass('selected')
          else
            $("#trash-bin").removeClass('selected')

        @graphView.on "node:dragend", (node, e) =>
          if @graphView.isContainedIn e.sourceEvent, $('#trash-bin')
            @model.deSelect node
            spokes = @model.connections.filter (c) ->
              (c.get('source') is node.get('_id')) or (c.get('target') is node.get('_id'))
            @model.deSelect spoke for spoke in spokes
            @model.removeNode node
            $("#trash-bin").removeClass('selected')

        @model.nodes.on 'add remove', @calcNumNodesHidden, this
        @model.on 'init', @calcNumNodesHidden, this

      calcNumNodesHidden: ->
        @model.getNodeNames (names) =>
          $('#number-hidden').text(names.length - @model.nodes.length)

      # This works quickly by loading the clientside prefetched nodes
      # right away and then updating them
      bringBackAll: ->
        if window.prefetch.nodes then @model.nodes.set window.prefetch.nodes, {silent:true}
        @model.nodes.fetch()
        if window.prefetch.connections then @model.connections.set window.prefetch.connections, {silent:true}
        @model.connections.fetch()

        @model.trigger "init"
