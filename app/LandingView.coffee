define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class LandingView extends Backbone.View
      el: $ '#button-container'

      events:
        'click #create': 'newGraphDoc'
        'click #open': 'openGraphDocModal'

      initialize: ->
        console.log "init LandingView"

      newGraphDoc: ->
        console.log "newGraphDoc"

      openGraphDocModal: ->
        console.log "openGraphDocModal"
