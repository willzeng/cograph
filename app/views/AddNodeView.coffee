define ['jquery', 'underscore', 'backbone', 'cs!models/WorkspaceModel', 'cs!models/NodeModel'],
  ($, _, Backbone, WorkspaceModel, NodeModel) ->
    class AddNodeView extends Backbone.View
      el: $ '#add-node-form'

      events:
        'focusout textarea': 'lessInformation'
        'focus .node-input': 'moreInformation'

      initialize: ->
        window.nm  = NodeModel

      moreInformation: ->
        @$el.find('.node-description').removeClass 'hide'

      lessInformation: (e) ->
        @$el.find('.node-description').addClass 'hide'

      addNode: (e) ->
        e.preventDefault()

        attributes = {_dodId: @model.nodes._docId}
        _.each $('#add-node-form').serializeArray(), (obj) ->
          attributes[obj.name] = obj.value

        node = new NodeModel attributes
        if node.isValid()
          node.save()
          @model.select @model.putNode node
          @$el[0].reset() # blanks out the form fields
        else
          $('input', @el).attr('placeholder', node.validate())
