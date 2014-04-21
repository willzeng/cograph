define ['jquery', 'underscore', 'backbone', 'js/GraphModel', 'js/GraphView'],
  ($, _, Backbone, GraphModel, GraphView) ->
    class Router extends Backbone.Router
      initialize: ->
        @graphModel = new GraphModel()
        @graphView = new GraphView model: @graphModel
        window.gm = @graphModel
        Backbone.history.start()

      routes:
        '': 'home'

      'home': ->
        @graphView.render()
