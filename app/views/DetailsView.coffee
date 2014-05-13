define ['jquery', 'underscore', 'backbone', 'backbone-forms', 'list',
 'text!templates/details_box.html', 'text!templates/edit_form.html'],
  ($, _, Backbone, bbf, list, detailsTemplate, editFormTemplate) ->
    class DetailsView extends Backbone.View
      el: $ '#graph'

      events:
        'click .close' : 'closeDetail'
        'click #edit-node-button': 'editNode'
        'click #edit-connection-button': 'editConnection'
        'click #save-node-connection-button': 'saveNodeConnection'

      initialize: ->
        @model.nodes.on 'change', @update, this
        @model.connections.on 'change', @update, this

      update: ->
        selectedNode = @getSelectedNode()
        selectedConnection = @getSelectedConnection()

        $("#details-container").empty()

        if selectedNode
          $("#details-container").append _.template(detailsTemplate, selectedNode)
        if selectedConnection
          $("#details-container").append _.template(detailsTemplate, selectedConnection)

      closeDetail: () ->
        $('#details-container').empty()
        if @getSelectedNode()
          @getSelectedNode().set 'selected', false
        if @getSelectedConnection()
          @getSelectedConnection().set 'selected', false

      editNode: () ->
        @editNodeConnection @getSelectedNode()

      editConnection: () ->
        @editNodeConnection @getSelectedConnection()

      editNodeConnection: (nodeConnection) ->
        @nodeConnectionForm = new Backbone.Form(
          model: nodeConnection
          template: _.template(editFormTemplate)
        ).render()

        $('#details-container .panel-body').empty().append(@nodeConnectionForm.el)

      saveNodeConnection: ->
        @nodeConnectionForm.commit()
        @update()

      getSelectedNode: ->
        selectedNode = @model.nodes.findWhere {'selected': true}

      getSelectedConnection: ->
        selectedConnection = @model.connections.findWhere {'selected': true}
