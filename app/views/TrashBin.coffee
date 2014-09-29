define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class TrashBin extends Backbone.View
      el: $ '#graph'
      that = this
      events:
        'click #bring-all-nodes-to-view', 'bringBackAll'

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

        @model.nodes.on 'remove', @calcNumNodesHidden, this

      calcNumNodesHidden: () =>
        @model.getNodeNames((names) =>
          console.log(names.length - @attributes.workspace.length)
          $('#number-hidden').text(names.length - @attributes.workspace.length)
        )

      bringBackAll: () =>
        console.log('bring back all nodes and connections')