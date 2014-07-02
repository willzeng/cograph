define ['jquery', 'backbone', 'bloodhound', 'typeahead', 'cs!models/WorkspaceModel'],
  ($, Backbone, Bloodhound, typeahead, WorkspaceModel) ->
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
            header: '<h4 class="text-center">Node Names</h4>'
        ,
          name: 'tags'
          source: findTagMatches
          templates:
            header: '<h4 class="text-center">Labels</h4>'
        )

        $('#search-input').on 'typeahead:selected',
          (e, sugg, dataset) => @search(sugg)

      search: (sugg) ->
        if sugg.type == 'node'
          node = @findLocalNode sugg.value
          if node
            @model.select node
          else
            @getNodeByName sugg.value
        else if sugg.type == 'tag'
          @model.getNodesByTag sugg.value, (nodes) =>
            @model.putNode node for node in nodes
        $('#search-input').val('')

      findLocalNode: (name) ->
        matchedNames = @findMatchingNames(name, @model.nodes.pluck('name'))
        @model.nodes.findWhere name: matchedNames[0]

      getNodeByName: (name) ->
        @model.getNodeByName name, (node) =>
          @model.select @model.putNodeFromData node

      findMatchingNames: (query, allNames) ->
        regex = new RegExp(query,'i')
        _.filter(allNames, (name) -> regex.test(name))

      findMatchingObjects: (query, allObjects) ->
        regex = new RegExp(query,'i')
        _.filter(allObjects, (object) -> regex.test(object.name))
