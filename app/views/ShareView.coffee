define ['jquery', 'underscore', 'backbone', 'text!templates/share_modal.html', 'share-button'],
  ($, _, Backbone, shareTemplate, shareButton) ->
    class ShareView extends Backbone.View
      el: $ '#graph'

      events:
        'click #share-button': 'saveWorkspace'

      initialize: ->
        @toggleShown = false

        new shareButton "#share-button",
          ui:
            flyout: 'middle left'

        popoverTemplate = '''
          <div class="popover" role="tooltip">
            <div class="arrow"></div>
            <h3 class="popover-title"></h3>
            <form role="form">
              <div class="form-group">
                <input type="text" placeholder="Untitled Doc"></input>
              </div>
            </form>
          </div>'
        '''
        $('#share-button').popover
          template: popoverTemplate

      saveWorkspace: ->
        if !(@toggleShown)
          @model.sync "create", @model,
            success: (savedModel) => @trigger "save:workspace", savedModel._id
        @toggleShown = !@toggleShown
