define ['jquery', 'underscore', 'backbone', 'backbone-forms', 'list',
 'text!templates/details_box.html', 'text!templates/edit_node_form.html'],
  ($, _, Backbone, bbf, list, detailsTemplate, nodeEditFormTemplate) ->
    class DetailsView extends Backbone.View

      el: $ '#graph'

      events:
        'click .close' : 'closeDetail'
        'click #edit-node-button': 'editNode'
        'click #save-node-button': 'saveNode'

      initialize: ->
        @model.nodes.on 'change', @update, this

      update: ->
        selectedNode = @getSelectedNode()

        $("#details-container").empty()

        if selectedNode
          $("#details-container").append _.template(detailsTemplate, selectedNode)

      closeDetail: () ->
        $('#details-container').empty()
        @getSelectedNode().set 'selected', false

      editNode: () ->
        selectedNode = @model.nodes.findWhere {'selected': true}
        @nodeForm = new Backbone.Form(
          model: selectedNode
          template: _.template(nodeEditFormTemplate)
        ).render()

        $('#details-container .panel-body').empty().append(@nodeForm.el)

      saveNode: (e) ->
        @nodeForm.commit()
        @update()

      getSelectedNode: ->
        selectedNode = @model.nodes.findWhere {'selected': true}
