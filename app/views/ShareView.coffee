define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button', 'text!templates/save_view_modal.html'],
  ($, _, Backbone, shareTemplate, shareButton, saveDocTemplate) ->
    class ShareView extends Backbone.View
      el: $ 'body'

      events:
        'click #share-workspace-button': 'shareWorkspace'

      initialize: ->
        @updatePublicButton()
        @model.getDocument().on 'change:public', @updatePublicButton, this

      shareWorkspace: ->
        @shareDocModal = new Backbone.BootstrapModal(
          content: _.template(shareTemplate, {})
          title: "Share View"
          animate: true
          showFooter: false
        ).open()

      updatePublicButton: ->
        if @model.getDocument().get 'publicView'
          $('.public-button-display').html '<i class="fa fa-globe" title="public"></i>'
        else
          $('.public-button-display').html '<i class="fa fa-lock" title="private"></i>'