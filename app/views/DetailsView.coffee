define ['jquery', 'underscore', 'backbone', 'backbone-forms', 'list', 'backbone-forms-bootstrap', 'bootstrap', 'bb-modal',
 'text!templates/details_box.html', 'text!templates/edit_form.html', 'cs!models/NodeModel', 'cs!models/ConnectionModel',
 'bootstrap-color'],
  ($, _, Backbone, bbf, list, bbfb, Bootstrap, bbModal, detailsTemplate, editFormTemplate, NodeModel, ConnectionModel, ColorPicker) ->
    class DetailsView extends Backbone.View
      el: $ 'body'

      events:
        'click .close' : 'closeDetail'
        'click #edit-node-button': 'editNodeConnection'
        'click #edit-connection-button': 'editNodeConnection'
        'submit form': 'saveNodeConnection'
        'click #archive-node-button': 'archiveObj'
        'click #archive-connection-button': 'archiveObj'
        'click #delete-button': 'deleteObj'
        'click #expand-node-button': 'expandNode'

      initialize: ->
        @graphView = @attributes.graphView

        @model.on 'conn:clicked', @openDetails, this
        @model.on 'node:clicked', @openDetails, this
        @model.on 'create:connection', @openAndEditConnection, this

      openDetails: (nodeConnection) ->
        @currentNC = nodeConnection
        workspaceSpokes = @model.getSpokes nodeConnection
        @updateColor @model.defaultColors[nodeConnection.get('color')]
        nodeConnection.on "change:color", (nc) => @updateColor @model.defaultColors[nodeConnection.get('color')]

        @detailsModal = new Backbone.BootstrapModal(
          content: _.template(detailsTemplate, {node:nodeConnection, spokes:workspaceSpokes})
          animate: false
          showFooter: false
        ).open()
        @editNodeConnection()

      updateColor: (color) ->
        $('#details-container .panel-heading').css 'background', color

      closeDetail: () ->
        @detailsModal.close()
        @graphView.trigger "node:mouseout"

      openAndEditConnection: (conn) ->
        @currentNC = conn
        @openDetails conn
        @editNodeConnection()

      editNodeConnection: ->
        nodeConnection = @currentNC
        @nodeConnectionForm = new Backbone.Form(
          model: nodeConnection
          template: _.template(editFormTemplate)
        ).on('name:blur url:blur tags:blur', (form, editor) ->
          form.fields[editor.key].validate()
        ).render()

        $('#details-container .panel-body').empty().append(@nodeConnectionForm.el)
        $('input[name=name]', @el).focus()

        isNode = nodeConnection.constructor.name is 'NodeModel'
        colorOptions = colors:[(val for color, val of @model.defaultColors when !((color is 'grey') and isNode))]
        $('.colorpalette').colorPalette(colorOptions).on 'selectColor', (e) =>
          colorValue = e.color
          nodeConnection.set 'color', _.invert(@model.defaultColors)[colorValue]
          nodeConnection.save()

      saveNodeConnection: (e) ->
        e.preventDefault()
        @nodeConnectionForm.commit()
        @nodeConnectionForm.model.save()
        @closeDetail()
        false

      archiveObj: ->
        if @currentNC.constructor.name is "NodeModel"
          @model.removeNode @currentNC
        else if @currentNC.constructor.name is "ConnectionModel"
          @model.removeConnection @currentNC
        @closeDetail()

      deleteObj: ->
        if @currentNC.constructor.name is "NodeModel"
          @model.deleteNode @currentNC
        else if @currentNC.constructor.name is "ConnectionModel"
          @model.deleteConnection @currentNC
        @closeDetail()

      expandNode: ->
        @currentNC.getNeighbors (neighbors) =>
          for node in neighbors
            newNode = new NodeModel node
            if @model.putNode newNode #this checks to see if the node has passed the filter
              newNode.getConnections @model.nodes, (connections) =>
                @model.putConnection new ConnectionModel conn for conn in connections
