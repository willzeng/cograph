define ['jquery', 'backbone', 'bloodhound', 'typeahead', 'cs!models/GraphModel'],
  ($, Backbone, Bloodhound, typeahead, GraphModel) ->
    class SearchView extends Backbone.View
      el: $ '#search-form'

      events:
        'click button': 'search'

      initialize: ->
        substringMatcher = (gm) ->
          findMatches = (q, cb) ->
            substrRegex = new RegExp(q, "i")
            names = gm.nodes.pluck 'name'
            matches = _.filter(names, (name) -> substrRegex.test(name))
            matches = _.map matches, (name) -> value: name
            cb matches

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
        node = @findNode searchTerm
        if node
          @model.selectNode node
          $('#search-input').val('')

      findNode: (name) ->
        regex = new RegExp(name,'i') #this is to do a case insensitive match
        allNames = @model.nodes.pluck 'name'
        firstMatchedNodeName = (regex.exec allNames)[0]
        @model.nodes.findWhere name: firstMatchedNodeName
