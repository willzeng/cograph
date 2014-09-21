define ['jquery', 'underscore', 'backbone', 'cs!mobile/views/MobileView'],
  ($, _, Backbone, MobileView) ->
    class mobileRouter extends Backbone.Router
      
      initialize: ->
        @mobileView = new MobileView()
        Backbone.history.start()

      routes:
        '': 'home'
        '(:id)': 'docSpecified'

      home: ->

      docSpecified: (id) ->
        @mobileView.docId = id