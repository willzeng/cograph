define ['jquery', 'underscore', 'backbone', 'cs!models/WorkspaceModel', 'cs!models/NodeModel'],
  ($, _, Backbone, WorkspaceModel, NodeModel) ->
    class AddNodeView extends Backbone.View
      el: $ '#add-node-form'

      events:
        'focusout textarea': 'lessInformation'
        'focus .node-input': 'moreInformation'
        'submit': 'addNode'
        'focusout .node-input': 'lessInformation'

      initialize: ->
        $('.node-description > textarea').on 'keydown', (e) =>
          keyCode = e.keyCode || e.which
          if keyCode == 13 # code for ENTER
            @addNode()

      moreInformation: ->
        @$el.find('.node-description').removeClass 'hide'
        @descriptionFocus = false
        $('.node-description').hover () =>
          @descriptionFocus = true
        , () => @descriptionFocus = false

        # TAB focues on description
        $('.node-input').on 'keydown', (e) =>
          keyCode = e.keyCode || e.which
          if keyCode == 9 # code for TAB
            e.preventDefault()
            @descriptionFocus = true
            $('.node-description > textarea').focus()
            @descriptionFocus = false

      lessInformation: (e) ->
        # Don't hide info if focusing on it
        if !@descriptionFocus
          @$el.find('.node-description').addClass 'hide'

      addNode: (e) ->
        if e? then e.preventDefault()

        attributes = {_dodId: @model.nodes._docId}
        _.each $('#add-node-form').serializeArray(), (obj) ->
          attributes[obj.name] = obj.value

        node = new NodeModel attributes
        if node.isValid()
          node.save()
          @model.select @model.putNode node
          @$el[0].reset() # blanks out the form fields
          @lessInformation()
        else
          $('input', @el).attr('placeholder', node.validate())
