define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button'],
  ($, _, Backbone, shareTemplate, shareButton) ->
    class ShareView extends Backbone.View
      el: $ 'body'

      events:
        'click #sharing-button': 'openShareModal'
        'click #save-workspace-button': 'saveWorkspace'
        'click .public-button': 'togglePublic'

      initialize: ->
        @updatePublicButton()
        @model.getDocument().on 'change:public', @updatePublicButton, this

      openShareModal: ->
        @newShareModal = new Backbone.BootstrapModal(
          content: _.template(shareTemplate, {})
          animate: true
          showFooter: false
        ).open()

        @newShareModal.on "shown", () ->
          new shareButton ".network-share-button"

        $('button', @newShareModal.$el).click () =>
          @newShareModal.close()

      saveWorkspace: ->
        @model.sync "create", @model,
          success: (savedModel) => @trigger "save:workspace", savedModel._id

      updatePublicButton: ->
        if @model.getDocument().get 'public'
          $('.public-button').text 'Make GraphDoc private'
        else
          $('.public-button').text 'Make GraphDoc public'

      togglePublic: ->
        doc = @model.getDocument()
        doc.set "public", not doc.get "public"
        doc.save()
