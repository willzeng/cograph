define ['jquery', 'underscore', 'backbone', 'cs!models/WorkspaceModel', 'cs!models/NodeModel',
'atwho', 'twittertext'],
  ($, _, Backbone, WorkspaceModel, NodeModel, atwho, twittertext) ->
    class AddNodeView extends Backbone.View
      el: $ '#add-node-form'

      events:
        'focusout textarea': 'lessInformation'
        'focus .node-input': 'moreInformation'
        'submit': 'addNode'
        'focusout .node-input': 'lessInformation'

      initialize: ->
        @descriptionArea = $('.node-description > textarea')
        @descriptionArea.on 'shown.atwho', (e) =>
          @showingAtWho = true
        @descriptionArea.on 'hidden.atwho', (e) =>
          @showingAtWho = false

        @descriptionArea.on 'keydown', (e) =>
          keyCode = e.keyCode || e.which
          # code for ENTER
          if keyCode == 13 and !@showingAtWho
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
            @descriptionArea.focus()
            @descriptionFocus = false

        # Add atwho dropdowns to the description box
        @descriptionArea.atwho
          at: "@"
          data: @model.nodes.pluck('name')
          target: "#add-node-form"
        .atwho
          at: "#"
          data: @model.filterModel.getTags('node')
          target: "#add-node-form"

      lessInformation: (e) ->
        # Don't hide info if focusing on it
        if !@descriptionFocus
          @$el.find('.node-description').addClass 'hide'
          @descriptionArea.atwho 'destroy'

      addNode: (e) ->
        if e? then e.preventDefault()

        attributes = {_docId: @model.nodes._docId}
        _.each $('#add-node-form').serializeArray(), (obj) ->
          attributes[obj.name] = obj.value

        attributes.selected = true

        node = new NodeModel attributes
        if node.isValid()
          @model.putNode node
          node.set "tags", twttr.txt.extractHashtags attributes.description

          $.when(node.save()).then =>
            # Create connections to mentioned nodes
            names = twttr.txt.extractMentions attributes.description

            for name in _.uniq names
              targetNode = @model.nodes.findWhere {name:name}
              if targetNode?
                connection = new @model.connections.model
                    source: node.get('_id')
                    target: targetNode.get('_id')
                    _docId: @model.documentModel.get('_id')
                    description: node.get('description')
                connection.save()
                @model.putConnection connection

          @$el[0].reset() # blanks out the form fields
          @descriptionFocus = false
        else
          $('input', @el).attr('placeholder', node.validate())
