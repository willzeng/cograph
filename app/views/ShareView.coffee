define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button'],
  ($, _, Backbone, shareTemplate, shareButton) ->
    class ShareView extends Backbone.View
      el: $ '#graph'

      events:
        'click #share-button': 'saveWorkspace'
        'focusout #workspace-name': 'nameWorkspace'

      initialize: ->
        @toggleShown = false

        @share = new shareButton "#share-button",
          ui:
            flyout: 'middle left'

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
        $('#share-button').popover
          template: popoverTemplate

      nameWorkspace: ->
        @model.set 'name', $('#workspace-name').val()
        @model.sync "update", @model

      saveWorkspace: ->
        if !(@toggleShown)
          @model.sync "create", @model,
            success: (savedModel) => @trigger "save:workspace", savedModel._id
        @toggleShown = !@toggleShown
