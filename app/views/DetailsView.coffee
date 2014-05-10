define ['jquery', 'underscore', 'backbone', 'backbone-forms', 'list',
 'text!templates/details_node_box.html', 'text!templates/details_connection_box.html', 'text!templates/edit_node_form.html', 'text!templates/edit_connection_form.html'],
  ($, _, Backbone, bbf, list, nodeDetailsTemplate, connectionDetailsTemplate, nodeEditFormTemplate, connectionEditFormTemplate) ->
    class DetailsView extends Backbone.View

      el: $ '#graph'

      events:
        'click .close' : 'closeDetail'
        'click #edit-node-button': 'editNode'
        'click #save-node-button': 'saveNode'
        'click #edit-connection-button': 'editConnection'
        'click #save-connection-button': 'saveConnection'

      initialize: ->
        @model.nodes.on 'change', @update, this
        @model.connections.on 'change', @update, this

      update: ->
        selectedNode = @getSelectedNode()
        selectedConnection = @getSelectedConnection()

        $("#details-container").empty()

        if selectedNode
          $("#details-container").append _.template(nodeDetailsTemplate, selectedNode)
        if selectedConnection
          $("#details-container").append _.template(connectionDetailsTemplate, selectedConnection)

      closeDetail: () ->
        $('#details-container').empty()
        if @getSelectedNode()
          @getSelectedNode().set 'selected', false
        if @getSelectedConnection()
          @getSelectedConnection().set 'selected', false

      editNode: () ->
        selectedNode = @model.nodes.findWhere {'selected': true}
        @nodeForm = new Backbone.Form(
          model: selectedNode
          template: _.template(nodeEditFormTemplate)
        ).render()

        $('#details-container .panel-body').empty().append(@nodeForm.el)

      editConnection: () ->
        selectedConnection = @model.connections.findWhere {'selected': true}
        @connectionForm = new Backbone.Form(
          model: selectedConnection
          template: _.template(connectionEditFormTemplate)
        ).render()
        console.log @connectionForm
        $('#details-container .panel-body').empty().append(@connectionForm.el)

      saveNode: (e) ->
        @nodeForm.commit()
        @update()

      saveConnection: (e) ->
        @connectionForm.commit()
        @update()

      getSelectedNode: ->
        selectedNode = @model.nodes.findWhere {'selected': true}

      getSelectedConnection: ->
        selectedConnection = @model.connections.findWhere {'selected': true}
