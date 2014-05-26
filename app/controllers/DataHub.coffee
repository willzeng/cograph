define ['jquery', 'underscore', 'backbone', 'cs!controllers/DataController', 'cs!views/DetailsView'],
($, _, Backbone, DataController, DetailsView) ->
  class DataHub extends Backbone.View

    initialize: ->
      @model.nodes.on 'add', @nodeAdd, this

      @model.on 'delete', @nodeDelete, this

    nodeAdd:(node) ->
      if node.get('_id') < 0
        DataController.nodeAdd node

    nodeDelete:(node) ->
      DataController.nodeDelete node