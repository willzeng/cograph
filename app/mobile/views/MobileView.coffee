define ['jquery', 'underscore', 'backbone', 'bloodhound', 'typeahead', 'cs!models/NodeModel', 'cs!models/ConnectionModel', 'socket-io'],
  ($, _, Backbone, Bloodhound, typeahead, NodeModel, ConnectionModel, io) ->
    class MobileView extends Backbone.View
      el: $ 'body'
      docId = 6848

      initialize: ->
        console.log "init mobileview"

      events:
          'click #add-connection-tab': 'switchTabsToConnection'
          'click #add-node-tab': 'switchTabsToNode'
          'click #cancel-node': 'cancelNode'
          'click #add-node': 'addNode'
          'click #add-connection-node': 'addConnectionNode'
          'click #cancel-connection': 'cancelConnection'

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
        else
          $('#node-name').removeClass('red')
          console.log $('.node > input[type="text"]').val()
          nameText = $('.node > input[type="text"]').val()

          newNode = new NodeModel {name:nameText, _docId: docId}
          newNode.save()

          $('.node > input[type="text"]').val("")

      addConnectionNode: ->
        if $('#node-name').val() == ""
          $('#node-name').addClass('red')
        else
          console.log($('.node > input[type="text"]').val());
          $('#source-node-name').val($('#node-name').val())
          $('.node > input[type="text"]').val("")
          switchTabsToConnection()

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
            console.log($('.connection > input[type="text"]').val());
            #send data to server
            $('.connection > input[type="text"]').removeClass('red');
            $('.connection > input[type="text"]').val("");
