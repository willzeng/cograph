define ['jquery', 'backbone', 'cs!models/WorkspaceModel', 'cs!models/NodeModel'],
  ($, Backbone, WorkspaceModel, NodeModel) ->
    class AddNodeView extends Backbone.View
      el: $ '#add-node-form'

      events:
        'submit': 'addNode'

      addNode: ->
        node_name = $('input', @el).val()
        docId = @model.nodes._docId
        node = new NodeModel {name: node_name, _docId: docId}
        if node.isValid()
          node.save()
          @model.select @model.putNode node
          $('input', @el).val('')
        else
          $('input', @el).attr('placeholder', 'Node must have name!')
        false # return false to prevent form from routing to new url
