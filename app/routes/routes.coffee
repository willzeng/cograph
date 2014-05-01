define ['jquery', 'underscore', 'backbone', 'cs!models/GraphModel',
  'cs!views/GraphView', 'cs!views/AddNodeView', 'cs!views/DetailsView', 'cs!views/SidebarView'],
  ($, _, Backbone, GraphModel, GraphView, AddNodeView, DetailsView, SidebarView) ->
    class Router extends Backbone.Router
      initialize: ->
        @graphModel = new GraphModel()
        @graphView = new GraphView model: @graphModel
        @addNodeView = new AddNodeView model: @graphModel
        @detailsView = new DetailsView model: @graphModel
        @sidebarView = new SidebarView model: @graphModel
        window.gm = @graphModel
        Backbone.history.start()

      routes:
        '': 'home'

      home: ->
        @graphView.render()
        gm.nodes.add
          name: 'one'
          description: 'The first one'
          tags: ["lux", "et", "veritas"]

        gm.nodes.add
          name: 'two'

        gm.connections.add
          name: 'related to'
          source: 0
          target: 1
