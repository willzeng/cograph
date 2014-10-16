define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button', 'text!templates/save_view_modal.html'],
  ($, _, Backbone, shareTemplate, shareButton, saveDocTemplate) ->
    class ShareView extends Backbone.View
      el: $ 'body'

      events:
        'click #share-workspace-button': 'shareWorkspace'

      initialize: ->
        @graphView = @attributes.graphView
        @updatePublicButton()
        @model.getDocument().on 'change:public', @updatePublicButton, this

        $('#embed-button').popover
          content: @getEmbed window.location

        @model.on 'navigate', (dest) =>
          $('#embed-button').data('bs.popover').options.content = @getEmbed dest

      shareWorkspace: ->
        @shareDocModal = new Backbone.BootstrapModal(
          content: _.template(shareTemplate, {})
          title: "Share View"
          animate: true
          showFooter: false
        ).open()

      updatePublicButton: ->
        if @model.getDocument().get 'publicView' != 0
          $('.public-button-display').html '<i class="fa fa-globe" title="public"></i>'
        else
          $('.public-button-display').html '<i class="fa fa-lock" title="private"></i>'

      togglePublic: ->
        doc = @model.getDocument()
        doc.set "public", not doc.get "public"
        doc.save()

      getEmbed: (url) ->
        """
        <div style = 'min-width:420;max-width:700'>
          <iframe src='#{url}' width='100%' height='100%'
          scrolling='no' frameborder='0' allowfullscreen>
          </iframe>
        </div>
        """