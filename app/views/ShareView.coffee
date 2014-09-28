define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button'],
  ($, _, Backbone, shareTemplate, shareButton) ->
    class ShareView extends Backbone.View
      el: $ 'body'

      events:
        'click #save-workspace-button': 'saveWorkspace'
        'click .public-button': 'togglePublic'
        'focusout #workspace-name': 'nameWorkspace'

      initialize: ->
        @updatePublicButton()
        @model.getDocument().on 'change:public', @updatePublicButton, this

        @toggleShown = false

        @share = new shareButton "#phantom-share",
          ui:
            flyout: 'middle top'
        $('.entypo-export').hide()
        $('#sharing-button').click -> $('.entypo-export').trigger 'click'

        popoverTemplate = '''
          <div class="popover" role="tooltip">
            <div class="arrow"></div>
            <h3 class="popover-title"></h3>
            <form role="form">
              <div class="form-group">
                <input id="workspace-name" type="text" placeholder="Untitled Doc"></input>
              </div>
            </form>
          </div>'
        '''
        $('#save-workspace-button').popover
          template: popoverTemplate

        str = "<iframe src=\"#{window.location}\" width=\"860\" height=\"700\" scrolling=\"no\" frameborder=\"0\" allowfullscreen></iframe>"
        $('#embed-button').popover
          content: str

        @model.on 'navigate', (dest) =>
          $('#embed-button').data('bs.popover').options.content = "<iframe src=\"#{@model.root+dest}\" width=\"860\" height=\"700\" scrolling=\"no\" frameborder=\"0\" allowfullscreen></iframe>"

      nameWorkspace: ->
        @model.set 'name', $('#workspace-name').val()
        @model.sync "update", @model

      saveWorkspace: ->
        if !(@toggleShown)
          @model.sync "create", @model,
            success: (savedModel) => @trigger "save:workspace", savedModel._id
        else
          $('#workspace-name').val("")
        @toggleShown = !@toggleShown

      updatePublicButton: ->
        if @model.getDocument().get 'public'
          $('.public-button').html '<i class="fa fa-globe"></i>'
        else
          $('.public-button').html '<i class="fa fa-lock"></i>'

      togglePublic: ->
        doc = @model.getDocument()
        doc.set "public", not doc.get "public"
        doc.save()
