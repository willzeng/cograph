define ['jquery', 'backbone', 'bloodhound', 'typeahead', 'bootstrap'],
  ($, Backbone, Bloodhound, typeahead, bootstrap) ->
    class MenuView extends Backbone.View
      el: $ '#menu-bar'

      events:
          'keypress #menu-title': 'removeNewlines'

      removeNewlines: (e) ->
        if e.which == 13
          $('#menu-title').blur()