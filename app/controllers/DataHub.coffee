define ['jquery', 'underscore', 'backbone', 'cs!controllers/DataController'],
($, _, Backbone, DataController) ->
  class DataHub extends Backbone.View

    initialize: ->
      @model.nodes.on 'add', @nodeAdd, this

    nodeAdd:(node) ->
      if !node.get('in_DB')
        DataController.nodeAdd node