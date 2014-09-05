define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button'],
  ($, _, Backbone, shareTemplate, shareButton) ->
    class ShareView extends Backbone.View
      el: $ '#sidebar-right'

      events:
        'click #sharing-button': 'openShareModal'
        'click #save-workspace-button': 'saveWorkspace'

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
