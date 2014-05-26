define ['jquery', 'underscore', 'backbone', 'cs!controllers/DataController', 'cs!views/DetailsView'],
($, _, Backbone, DataController, DetailsView) ->
  class DataHub extends Backbone.View

    initialize: ->
      @model.nodes.on 'add', @nodeAdd, this
      @model.nodes.on 'change', @nodeEdit, this
      @model.on 'delete', @nodeDelete, this

      @ignoredAttributes = ['dim', 'selected']

    nodeAdd: (node) ->
      if node.get('_id') < 0
        DataController.nodeAdd node

    nodeEdit: (node) ->
      if _.difference(_.keys(node.changed), @ignoredAttributes).length
        if node.get('_id') >= 0
          DataController.nodeEdit node

    nodeDelete: (node) ->
      DataController.nodeDelete node
