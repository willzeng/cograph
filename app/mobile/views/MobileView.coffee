define ['jquery', 'underscore', 'backbone', 'bootstrap', 'bloodhound', 'typeahead', 'cs!models/NodeModel', 'cs!models/ConnectionModel', 'socket-io'],
  ($, _, Backbone, Bootstrap, Bloodhound, typeahead, NodeModel, ConnectionModel, io) ->
    class MobileView extends Backbone.View
      el: $ 'body'

      initialize: ->
        @docId = 0

        nodeNameMatcher = () =>
          findMatches = (q, cb) =>
            $.get "/document/#{@docId}/nodes", (nodes) =>
              @nodes = nodes
              matches = _.uniq @findMatchingObjects(q, nodes), (match) -> match.name
              cb _.map matches, (match) -> {value: match.name, type: 'node'}

        connectionNameMatcher = () =>
          findMatches = (q, cb) =>
            $.get "/document/#{@docId}/connections", (connections) =>
              matches = _.uniq @findMatchingObjects(q, connections), (match) -> match.name
              cb _.map matches, (match) -> {value: match.name, type: 'connection'}

        $('#source-node-name').focus ->
          $('#source-node-name').removeClass('red')
        $('#destination-node-name').focus ->
          $('#destination-node-name').removeClass('red')
        $('#connection-name').focus ->
          $('#connection-name').removeClass('red')
        $('#node-name').focus ->
          $('#node-name').removeClass('red')

        # TYPEAHEADS

        # Source Node
        $('#source-node-name').typeahead(
          hint: false,
          highlight: true,
          minLength: 0,
          autoselect: true
        ,
          name: 'node-names',
          source: nodeNameMatcher()
        )

        $('#source-caret').on 'click', () =>
          ev = $.Event("keydown")
          ev.keyCode = ev.which = 40
          $('#source-node-name').trigger ev


        $('#source-node-name').on 'typeahead:selected',
          (e, sugg, dataset) -> $('#connection-name').focus()

        # Target Node
        $('#destination-node-name').typeahead(
          hint: false,
          highlight: true,
          minLength: 0,
          autoselect: true
        ,
          name: 'node-names',
          source: nodeNameMatcher()
        )

        $('#target-caret').on 'click', () =>
          ev = $.Event("keydown")
          ev.keyCode = ev.which = 40
          $('#destination-node-name').trigger ev


        $('#destination-node-name').on 'typeahead:selected',
          (e, sugg, dataset) => @addConnection()

        # Connection Types
        $('#connection-name').typeahead(
          hint: false,
          highlight: true,
          minLength: 0,
          autoselect: true
        ,
          name: 'connection-names',
          source: connectionNameMatcher()
        )

        $('#connection-caret').on 'click', () =>
          ev = $.Event("keydown")
          ev.keyCode = ev.which = 40
          $('#connection-name').trigger ev


        $('#connection-name').on 'typeahead:selected',
          (e, sugg, dataset) -> $('#destination-node-name').focus()

      events:
          'click #add-node': 'addNode'
          'click #cancel-node': 'cancelNode'
          'click #add-connection-node': 'addConnectionNode'
          'click #cancel-connection': 'cancelConnection'
          'click #add-connection': 'addConnection'

      # BUTTONS

      # Add Node
      cancelNode: ->
        $('#node-name').removeClass('red')
        $('input[type="text"]').val("")
        $('#node-description').val("")

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

          $('input[type="text"]').val("")
          $('#node-description').val("")
          [true, newNode.get('name')]

      addConnectionNode: ->
        success = @addNode()
        if success[0]
          $('a[data-target="#connection"]').tab('show')
          $('#source-node-name').val success[1]

      # Add Connection
      cancelConnection: ->
        # $('.connection > input[type="text"]').removeClass('red')
        $('input').val("")

      addConnection: ->
        validated = true;
        if $('#connection-name').val() == ""
          validated = false
          console.log "dsds"
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
            tags: @parseTags $('#connection-tags').val()
            _docId: @docId
          connection.save()

          # $('.connection > input[type="text"]').removeClass('red')

          $('input').val("")
          $('#connection-description').val("")
          $('source-node-name').focus()

      # Helper Methods
      parseTags: (string) ->
        (tag.trim() for tag in string.split(','))

      findMatchingObjects: (query, allObjects) ->
        regex = new RegExp(query,'i')
        _.filter(allObjects, (object) -> regex.test(object.name))
