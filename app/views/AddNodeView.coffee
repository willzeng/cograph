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
            e.currentTarget.blur()
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

        # store inserted mentions
        @mentions = []
        @descriptionArea.on "inserted.atwho", (event, item) =>
          insertedText = item.attr 'data-value'
          if insertedText[0] is "@"
            addedMention = @model.nodes.findWhere({name:insertedText.slice(1)})
            @mentions.push addedMention

      lessInformation: (e) ->
        # Don't hide info if focusing on it
        if !@descriptionFocus
          @$el.find('.node-description').addClass 'hide'
          @descriptionArea.atwho 'destroy'
          $('div[id=atwho-container]').remove() # removes all instances of the atwho-container

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
            @lessInformation()
            # Create connections to mentioned nodes
            @mentions = _.filter @mentions, (m) -> attributes.description.indexOf(m.get('name')) > 0
            uniqMentions = _.uniq @mentions, null, (n) -> n.get('name')

            for targetNode in uniqMentions
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
