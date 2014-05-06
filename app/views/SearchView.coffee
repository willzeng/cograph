define ['jquery', 'backbone', 'bloodhound', 'typeahead', 'cs!models/GraphModel'], ($, Backbone, Bloodhound, typeahead, GraphModel) ->
  class SearchView extends Backbone.View
    initialize: ->
      $('#search-form #search-input').on('typeahead:selected', 
        (e, sugg, dataset) -> 
          console.log sugg
          @model.selectNode datum
          return
      )
      $('#search-form').submit =>
        return false
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
      $('#search-form #search-input').typeahead({
        hint: true,
        highlight: true,
        minLength: 1,
        autoselect: true
      },
      {
        name: 'matching-nodes',
        source: substringMatcher(nodes),
        #updater: 
        templates: {
          empty: (o) -> 
            return '<p class="add-new-tt"><a id="add-new-tt"><i style="font-size:18px;position:relative;top:2px;margin-right:5px;" class="ion-ios7-plus-empty"></i>Add as a new node</a></p>'
        }
      })