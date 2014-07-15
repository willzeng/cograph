define ['jquery', 'underscore', 'backbone', 'bootstrap', 'bloodhound', 'typeahead', 'cs!models/NodeModel', 'cs!models/ConnectionModel', 'socket-io', 'text!templates/mobile_alert.html'],
  ($, _, Backbone, Bootstrap, Bloodhound, typeahead, NodeModel, ConnectionModel, io, mobile_alert) ->
    class MobileView extends Backbone.View
      el: $ 'body'

      events:
          'click #add-node': 'addNode'
          'click #cancel-node': 'cancelNode'
          'click #add-connection-node': 'addConnectionNode'
          'click #cancel-connection': 'cancelConnection'
          'click #add-connection': 'addConnection'

      initialize: ->
        @docId = 0

        $('.name-input').focus (e) ->
          $(e.currentTarget).removeClass('red')

        # TYPEAHEADS

        # fetch methods for typeaheads
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

        typeaheadConfig =
          hint: false,
          highlight: true,
          minLength: 0,
          autoselect: true

        $('.name-input').blur (e) ->
          $(e.currentTarget).typeahead('close')

        # trigger typeahead dropdowns with caret buttons
        $('.typeahead-caret').on 'click', (e) =>
          targetInput = $(e.currentTarget).attr('data-target')
          ev = $.Event("keydown")
          ev.keyCode = ev.which = 40
          $(targetInput).trigger ev
          $(targetInput).focus()

        # Source Node
        $('#source-node-name').typeahead typeaheadConfig,
          name: 'node-names',
          source: nodeNameMatcher()

        $('#source-node-name').on 'typeahead:selected',
          (e, sugg, dataset) -> $('#connection-name').focus()

        # Target Node
        $('#destination-node-name').typeahead typeaheadConfig,
          name: 'node-names',
          source: nodeNameMatcher()

        $('#destination-node-name').on 'typeahead:selected',
          (e, sugg, dataset) => @addConnection()

        # Connection Types
        $('#connection-name').typeahead typeaheadConfig,
          name: 'connection-names',
          source: connectionNameMatcher()

        $('#connection-name').on 'typeahead:selected',
          (e, sugg, dataset) -> $('#destination-node-name').focus()

      # BUTTONS

      # Add Node
      cancelNode: ->
        $('#node-name').removeClass('red')
        $('#node .form-control').val("")

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

          $('#node .form-control').val("")
          @setupAlert()

          [true, newNode.get('name')]

      addConnectionNode: ->
        success = @addNode()
        if success[0]
          $('a[data-target="#connection"]').tab('show')
          $('#source-node-name').val success[1]
          @setupAlert()

      # Add Connection
      cancelConnection: ->
        $('.name-input').removeClass 'red'
        $('#connection .form-control').val("")

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
            tags: @parseTags $('#connection-tags').val()
            _docId: @docId
          connection.save()

          @setupAlert()
          $('#connection .form-control').blur().val("")
          $('#source-node-name').focus()

      # Helper Methods
      setupAlert: () ->
        $('body').append((d) -> _.template(mobile_alert, d))
        setTimeout () ->
          $('.alert').remove()
        , 2500

      parseTags: (string) ->
        (tag.trim() for tag in string.split(','))

      findMatchingObjects: (query, allObjects) ->
        regex = new RegExp(query,'i')
        _.filter(allObjects, (object) -> regex.test(object.name))
