define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button', 'text!templates/save_view_modal.html'],
  ($, _, Backbone, shareTemplate, shareButton, saveDocTemplate) ->
    class ShareView extends Backbone.View
      el: $ 'body'

      events:
        'click #save-workspace-button': 'saveWorkspaceModal'
        'click #share-workspace-button': 'shareWorkspace'

      initialize: ->
        @graphView = @attributes.graphView
        @showingShareButtons = false

        $('#sharing-toggle').click =>
          if(@showingShareButtons) 
            @share.close()
          else
            @saveWorkspace "", ->
              $('.entypo-export').trigger 'click'
          @showingShareButtons = !@showingShareButtons

        $('#graph').click => if @showingShareButtons then $('#sharing-toggle').trigger 'click'

      updateSharing: ->
        @share = new shareButton "#phantom-share",
          ui:
            flyout: 'bottom right'
          title: "Check out "+@model.documentModel.get('name')+" on cograph."
          networks:
            pinterest:
              enabled: false
            email:
              description: "Check out "+@model.documentModel.get('name')+" on cograph at "+window.location.href+"."
            facebook:
              title: @model.documentModel.get('name')+" on cograph"
              description: "Check out "+@model.documentModel.get('name')+" on cograph."
              app_id: 315770905267996
            twitter:
              description: "Check out "+@model.documentModel.get('name')+" on cograph: "

        $('.entypo-export').hide()

      saveWorkspace: (name, cb) ->
        @model.sync "create", @model,
          success: (savedModel) =>
            @trigger "save:workspace", savedModel._id
            @model.set 'name', name || ""
            @model.sync "update", @model
            @updateSharing()
            if cb then cb()

      saveWorkspaceModal: ->
        @saveDocModal = new Backbone.BootstrapModal(
          content: _.template(saveDocTemplate, {})
          title: "Save View"
          animate: true
          showFooter: false
        ).open()

        @saveDocModal.on "shown", () ->
          $('#saveDocName').focus()

        @model.set 'zoom', @graphView.zoom.scale()
        @model.set 'translate', @graphView.zoom.translate()

        $('#save-doc-form', @saveDocModal.$el).submit () =>
          @saveWorkspace $('#saveDocName').val()
          @saveDocModal.close()
          false

      shareWorkspace: ->
        @shareDocModal = new Backbone.BootstrapModal(
          content: _.template(shareTemplate, {})
          title: "Share View"
          animate: true
          showFooter: false
        ).open()

