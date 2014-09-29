define ['jquery', 'backbone', 'bloodhound', 'typeahead', 'cs!models/WorkspaceModel', 'cs!models/ConnectionModel'],
  ($, Backbone, Bloodhound, typeahead, WorkspaceModel, ConnectionModel) ->
    class SearchView extends Backbone.View
      el: $ '#search-form'

      events:
        'click button': 'search'

      initialize: ->
        nodeNameMatcher = (gm) =>
          findMatches = (q, cb) =>
            gm.getNodeNames (matches) =>
              # matches come in id, name objects
              matches = @findMatchingObjects q, matches
              cb _.map matches, (match) -> {value: match.name, type: 'node'}

        connectionNameMatcher = (gm) =>
          findMatches = (q, cb) =>
            docId = @model.documentModel.get '_id'
            $.get "/document/#{docId}/connections", (connections) =>
              matches = _.uniq @findMatchingObjects(q, connections), (match) -> match.name
              cb _.map matches, (match) -> {value: match.name, type: 'connection'}

        findTagMatches = (q, cb) =>
          @model.getTagNames (tagNames) =>
            matches = @findMatchingNames q, tagNames
            cb _.map matches, (match) -> {value: match, type: 'tag'}

        $('#search-input').typeahead(
          hint: true,
          highlight: true,
          minLength: 1,
          autoselect: true
        ,
          name: 'node-names',
          source: nodeNameMatcher(@model)
          templates:
            header: '<span class="search-title">Nodes</span>'
        ,
          name: 'tags'
          source: findTagMatches
          templates:
            header: '<span class="search-title">Labels</span>'
        ,
          name: 'conn-names'
          source: connectionNameMatcher(@model)
          templates:
            header: '<span class="search-title">Connections</span>'
        )

        # David's Typeahead rage.
        x = $('.tt-dropdown-menu').remove()
        $('.twitter-typeahead').prepend(x)
        $('.tt-dropdown-menu').css('position', 'relative').css('top', 'auto').css('bottom', '5px')

        $('#search-input').on 'typeahead:selected',
          (e, sugg, dataset) => @search(sugg)

      search: (sugg) ->
        if sugg.type == 'node'
          node = @findLocalNode sugg.value
          if node
            @model.select node
            @model.trigger "found:node", node
          else
            @getNodeByName sugg.value, (node) =>
              # Give the graph some time to settle before centering
              setTimeout () =>
                @model.trigger "found:node", @model.nodes.findWhere {_id:node._id}
              , 1500
        else if sugg.type == 'tag'
          @model.getNodesByTag sugg.value, (nodes) =>
            for node in nodes
              localNode = @findLocalNode node.name
              if localNode
                @model.select localNode
              else
                @addNode node
        else if sugg.type == 'connection'
          conn = @findLocalConn sugg.value
          if conn
            @model.select conn
            @model.trigger "found:node", conn.source

          @model.getConnsByName sugg.value, (returnedConns) =>
            for c in returnedConns
              @model.putNodeFromData c.source
              @model.putNodeFromData c.target
              @model.putConnection new ConnectionModel c.connection
            # Give the graph some time to settle before centering
            setTimeout () =>
              @model.trigger "found:node", @model.nodes.findWhere({_id:returnedConns[0].source._id})
            , 500

        $('#search-input').val('')

      addNode: (nodeData) ->
        addedNode = @model.putNodeFromData nodeData, {force:true}
        addedNode.getConnections @model.nodes, (connections) =>
          @model.putConnection new ConnectionModel conn for conn in connections

      findLocalNode: (name) ->
        matchedNames = @findMatchingNames(name, @model.nodes.pluck('name'))
        @model.nodes.findWhere name: matchedNames[0]

      findLocalConn: (name) ->
        matchedNames = @findMatchingNames(name, @model.connections.pluck('name'))
        @model.connections.findWhere name: matchedNames[0]

      getNodeByName: (name, cb) ->
        @model.getNodeByName name, (node) =>
          @addNode node
          cb node

      findMatchingNames: (query, allNames) ->
        regex = new RegExp(query,'i')
        _.filter(allNames, (name) -> regex.test(name))

      findMatchingObjects: (query, allObjects) ->
        regex = new RegExp(query,'i')
        _.filter(allObjects, (object) -> regex.test(object.name))
