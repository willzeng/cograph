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
          $('.public-button').text 'Make GraphDoc private'
        else
          $('.public-button').text 'Make GraphDoc public'

      togglePublic: ->
        doc = @model.getDocument()
        doc.set "public", not doc.get "public"
        doc.save()
