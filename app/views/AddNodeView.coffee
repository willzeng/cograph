define ['jquery', 'backbone', 'cs!models/WorkspaceModel', 'cs!models/NodeModel',
'text!templates/add_template.html', 'text!templates/add_placeholder.html'],
  ($, Backbone, WorkspaceModel, NodeModel, adderTemplate, addPlaceholderTemplate) ->
    class AddNodeView extends Backbone.View
      el: $ '#add-node-form'

      events:
        'submit': 'addNode'
        'focus .node-input': 'showAdder'

      initialize: ->
        @appendPlaceholder()

      appendPlaceholder: ->
        $('#add-node-form').append _.template(addPlaceholderTemplate)

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

      hideAdder: ->
        $('#add-node-form').empty()
        @appendPlaceholder()

      showAdder: ->
        $('#add-node-form').empty()

        @adderForm = new Backbone.Form(
          model: new NodeModel
          template: _.template(adderTemplate)
        ).on('name:blur url:blur', (form, editor) ->
          form.fields[editor.key].validate()
        ).on('blur', (form, editor) =>
          @hideAdder()
        ).render()

        $("#add-node-form").append(@adderForm.el)
