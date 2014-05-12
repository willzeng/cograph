define ['jquery', 'backbone', 'cs!models/GraphModel'], ($, Backbone, GraphModel) ->
  class AddNodeView extends Backbone.View
    initialize: ->
      $('#add-node-form').submit =>
        node_name = $('#add-node-form [name=node-name]').val()
        @model.selectNode @model.nodes.add name: node_name, description: 'Default description'
        $('#add-node-form [name=node-name]').val('')
        false
