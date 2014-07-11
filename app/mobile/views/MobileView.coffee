define ['jquery', 'underscore', 'backbone', 'bloodhound', 'typeahead', 'cs!models/NodeModel', 'cs!models/ConnectionModel', 'socket-io'],
  ($, _, Backbone, Bloodhound, typeahead, NodeModel, ConnectionModel, io) ->
    class MobileView extends Backbone.View
      el: $ 'body'

      initialize: ->
        @docId = 6848

        $.get "/document/#{@docId}/nodes", (nodes) =>
          @nodes = nodes

      events:
          'click #add-connection-tab': 'switchTabsToConnection'
          'click #add-node-tab': 'switchTabsToNode'
          'click #cancel-node': 'cancelNode'
          'click #add-node': 'addNode'
          'click #add-connection-node': 'addConnectionNode'
          'click #cancel-connection': 'cancelConnection'
          'click #add-connection': 'addConnection'

      # TABS
      switchTabsToNode: ->
        $('#add-node-tab').addClass('selected')
        $('#add-connection-tab').removeClass('selected')
        $('.connection').addClass('hidden')
        $('.node').removeClass('hidden')

      switchTabsToConnection: ->
        $('#add-connection-tab').addClass('selected')
        $('#add-node-tab').removeClass('selected')
        $('.node').addClass('hidden')
        $('.connection').removeClass('hidden')

      # BUTTONS

      # Add Node
      cancelNode: ->
        $('#node-name').removeClass('red')
        $('.node > input[type="text"]').val("")

      addNode: ->
        if $('#node-name').val() == ""
          $('#node-name').addClass('red')
          [false]
        else
          $('#node-name').removeClass('red')

          newNode = new NodeModel
            name: $('#node-name').val()
            description: $('#node-description').val()
            tags: @parseTags $('#node-tags').val()
            _docId: @docId
          newNode.save()

          $('.node > input[type="text"]').val("")
          [true, $('#node-name').val()]

      addConnectionNode: ->
        success = @addNode()
        if success[0]
          @switchTabsToConnection()
          $('#source-node-name').val success[1]

      # Add Connection
      cancelConnection: ->
        $('.connection > input[type="text"]').removeClass('red')
        $('.connection > input[type="text"]').val("")

      addConnection: ->
        validated = true;
        if $('#connection-name').val() == ""
          validated = false
          $('#connection-name').addClass('red')

        if $('#source-node-name').val() == ""
          validated = false
          $('#source-node-name').addClass('red')

        if $('#destination-node-name').val() == ""
          validated = false
          $('#destination-node-name').addClass('red')

        if validated
          sourceNode = _.findWhere @nodes, {name:$('#source-node-name').val()}
          targetNode = _.findWhere @nodes, {name:$('#destination-node-name').val()}

          #send data to server
          connection = new ConnectionModel
            name: $('#connection-name').val()
            source: sourceNode._id
            target: targetNode._id
            description: $('#connection-description').val()
            tags: @parseTags $('#node-tags').val()
            _docId: @docId
          connection.save()

          $('.connection > input[type="text"]').removeClass('red')
          $('.connection > input[type="text"]').val("")

      # Helper Methods
      parseTags: (string) ->
        (tag.trim() for tag in string.split(','))
