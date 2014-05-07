define ['jquery', 'underscore', 'backbone', 'cs!models/GraphModel',
  'cs!views/GraphView', 'cs!views/AddNodeView', 'cs!views/DetailsView', 'cs!views/SearchView'],
  ($, _, Backbone, GraphModel, GraphView, AddNodeView, DetailsView, SearchView) ->
    class Router extends Backbone.Router
      initialize: ->
        @graphModel = new GraphModel()
        @graphView = new GraphView model: @graphModel
        @addNodeView = new AddNodeView model: @graphModel
        @detailsView = new DetailsView model: @graphModel
        @searchView = new SearchView model: @graphModel
        window.gm = @graphModel
        Backbone.history.start()

      routes:
        '': 'home'

      home: ->
        @graphView.render()
        gm.nodes.add
          name: 'Oxford'
          description: 'A City in the UK'
          tags: ["croquet", "rowing", "university"]

        gm.nodes.add
          name: 'David'

        gm.nodes.add
          name: 'Victor'

        gm.connections.add
          name: 'related to'
          source: gm.nodes.where({name:'Oxford'})
          target: gm.nodes.where({name:'David'})
