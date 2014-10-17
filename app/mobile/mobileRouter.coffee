define ['jquery', 'underscore', 'backbone', 'cs!mobile/views/MobileView'],
  ($, _, Backbone, MobileView) ->
    class mobileRouter extends Backbone.Router
      
      initialize: ->
        @mobileView = new MobileView()
        Backbone.history.start {pushState: true, root: "/mobile/"}

      routes:
        ':id': 'docSpecified'

      docSpecified: (id) ->
        @mobileView.docId = id