define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button', 'text!templates/save_view_modal.html'],
  ($, _, Backbone, shareTemplate, shareButton, saveDocTemplate) ->
    class ShareView extends Backbone.View
      el: $ 'body'

      events:
        'click #save-workspace-button': 'saveWorkspace'
        'click .public-button': 'togglePublic'
        'click #share-workspace-button': 'shareWorkspace'

      initialize: ->
        @updatePublicButton()
        @model.getDocument().on 'change:public', @updatePublicButton, this
        @showingShareButtons = false

        $('#embed-button').popover
          content: @getEmbed window.location

        @share = new shareButton "#phantom-share",
          ui:
            flyout: 'bottom right'
          title: "Check out "+@model.documentModel.get('name')+"on cograph"
          email:
            description: "Check out "+@model.documentModel.get('name')+"on cograph at"+window.location.href
          facebook:
            app_id: 315770905267996
          twitter:
            description: "Check out "+@model.documentModel.get('name')+"on cograph"

        $('.entypo-export').hide()
        $('#sharing-toggle').click =>
          $('.entypo-export').trigger 'click'
          @showingShareButtons = !@showingShareButtons

        $('#graph').click => if @showingShareButtons then $('#sharing-toggle').trigger 'click'

        @model.on 'navigate', (dest) =>
          $('#embed-button').data('bs.popover').options.content = @getEmbed dest

      saveWorkspace: ->
        @saveDocModal = new Backbone.BootstrapModal(
          content: _.template(saveDocTemplate, {})
          title: "Save View"
          animate: true
          showFooter: false
        ).open()

        @saveDocModal.on "shown", () ->
          $('#saveDocName').focus()

        $('#save-doc-form', @saveDocModal.$el).submit () =>
          @model.sync "create", @model,
            success: (savedModel) => 
              @trigger "save:workspace", savedModel._id
              @model.set 'name', $('#saveDocName').val()
              @model.sync "update", @model
          @saveDocModal.close()
          false

      shareWorkspace: ->
        @shareDocModal = new Backbone.BootstrapModal(
          content: _.template(shareTemplate, {})
          title: "Share View"
          animate: true
          showFooter: false
        ).open()

      updatePublicButton: ->
        if @model.getDocument().get 'public'
          $('.public-button').html '<i class="fa fa-globe" title="public"></i>'
        else
          $('.public-button').html '<i class="fa fa-lock" title="private"></i>'

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
