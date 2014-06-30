define ['jquery', 'backbone', 'bloodhound', 'typeahead', 'cs!models/WorkspaceModel'],
  ($, Backbone, Bloodhound, typeahead, WorkspaceModel) ->
    class SearchView extends Backbone.View
      el: $ '#search-form'

      events:
        'click button': 'search'

      initialize: ->
        substringMatcher = (gm) =>
          findMatches = (q, cb) =>
            gm.getNodeNames (matches) =>
              # matches come in id, name objects
              matches = @findMatchingObjects q, matches
              cb _.map matches, (match) -> {value: match.name}

        $('#search-input').typeahead(
          hint: true,
          highlight: true,
          minLength: 1,
          autoselect: true
        ,
          name: 'node-names',
          source: substringMatcher(@model)
        )

        $('#search-input').on 'typeahead:selected',
          (e, sugg, dataset) => @search()

      search: ->
        searchTerm = $('#search-input').val()
        node = @findLocalNode searchTerm
        if node
          @model.select node
          $('#search-input').val('')
        else
          @getNodeByName searchTerm
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
