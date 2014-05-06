define ['jquery', 'backbone', 'bloodhound', 'typeahead', 'cs!models/GraphModel'], ($, Backbone, Bloodhound, typeahead, GraphModel) ->
  class SearchView extends Backbone.View
    map = {}
    initialize: ->
      $('#search-form #search-input').on('typeahead:selected', 
        (e, sugg, dataset) => 
          console.log sugg
          @model.selectNode map[sugg.value]
          $('#search-form #search-input').val('')
          return
      )
    render: ->
      substringMatcher = (query) ->
        findMatches = (q, cb) ->
          matches = undefined
          substringRegex = undefined
          matches = []
          substrRegex = new RegExp(q, "i")
          $.each query, (i, str) ->
            matches.push value: str  if substrRegex.test(str)
            return
          cb matches
          return

      nodes = _.map(@model.nodes.models, (d) -> return d.attributes.name)
      
      _.each(@model.nodes.models, (d) ->
        map[d.attributes.name] = d
      )
      $('#search-form #search-input').typeahead({
        hint: true,
        highlight: true,
        minLength: 1,
        autoselect: true
      },
      {
        name: 'matching-nodes',
        source: substringMatcher(nodes),
        templates: {
          empty: (o) -> 
            return '<div style="color: grey;margin-left: 20px;padding: 3px 0px;"><i>No matches found</i></div>'
        }
      })
