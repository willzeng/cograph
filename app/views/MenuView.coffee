define ['jquery', 'backbone', 'bloodhound', 'typeahead'],
  ($, Backbone, Bloodhound, typeahead) ->
    class MenuView extends Backbone.View
      el: $ '#menu-bar'

      events:
          'click #menu-title': 'setTitleEditable',
          'blur #menu-title': 'setTitleUneditable'

      setTitleEditable: () ->
        $('#menu-title').attr 'contenteditable', 'true'

      setTitleUneditable: () ->
        $('#menu-title').attr 'contenteditable', 'false'
        if $('#menu-title').text() == ""
          $('#menu-title').text('Untitled Doc')