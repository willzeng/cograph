define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button', 'text!templates/save_view_modal.html'],
  ($, _, Backbone, shareTemplate, shareButton, saveDocTemplate) ->
    class ShareView extends Backbone.View
      el: $ 'body'

      events:
        'click #save-workspace-button': 'saveWorkspace'
        'click #public-button-edit': 'toggleEditPublic'
        'click #public-button-view': 'toggleViewPublic'
        'click #share-workspace-button': 'shareWorkspace'

      initialize: ->
        @updatePublicButton()
        @model.getDocument().on 'change:public', @updatePublicButton, this

      saveWorkspace: ->
        @saveDocModal = new Backbone.BootstrapModal(
          content: _.template(saveDocTemplate, {})
          title: "Save View"
          animate: true
          showFooter: false
        ).open()

        @saveDocModal.on "shown", () ->
          $('#saveDocName').focus()
          $("#save-doc-form").submit (e) ->
            false

        $('#save-doc-form', @saveDocModal.$el).submit () =>
          @model.sync "create", @model,
            success: (savedModel) => 
              @trigger "save:workspace", savedModel._id
              @model.set 'name', $('#saveDocName').val()
              @model.sync "update", @model
          @saveDocModal.close()

      shareWorkspace: ->
        @shareDocModal = new Backbone.BootstrapModal(
          content: _.template(shareTemplate, {})
          title: "Share View"
          animate: true
          showFooter: false
        ).open()

      updatePublicButton: ->
        if @model.getDocument().get 'public'
          $('.public-button-display').html '<i class="fa fa-globe" title="public"></i>'
        else
          $('.public-button-display').html '<i class="fa fa-lock" title="private"></i>'

      toggleEditPublic: ->
        doc = @model.getDocument()
        doc.set "public", not doc.get "public"
        doc.save()

      toggleViewPublic: ->

