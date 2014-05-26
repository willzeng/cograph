define ['jquery', 'backbone', 'cs!models/GraphModel', 'cs!models/NodeModel'],
  ($, Backbone, GraphModel, NodeModel) ->
    class AddNodeView extends Backbone.View
      el: $ '#add-node-form'

      events:
        'submit': 'addNode'

      addNode: ->
        node_name = $('input', @el).val()
        node = new NodeModel name: node_name
        if node.isValid()
          @model.selectNode @model.putNode node
          $('input', @el).val('')
        else
          $('input', @el).attr('placeholder', 'Node must have a name!')
        false # return false to prevent form from routing to new url
