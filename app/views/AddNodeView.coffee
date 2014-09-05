define ['jquery', 'underscore', 'backbone', 'cs!models/WorkspaceModel', 'cs!models/NodeModel',
'atwho', 'twittertext', 'elastic'],
  ($, _, Backbone, WorkspaceModel, NodeModel, atwho, twittertext) ->
    class AddNodeView extends Backbone.View
      el: $ '#add-node-form'

      events: 
        'submit' : 'addNode'

      initialize: ->
        @descriptionArea = $('#add-description')
        @titleArea = $('#add-title')
        @colorArea = $('#add-color')
        @imageArea = $('#add-image')

        @descriptionArea.elastic()
        @titleArea.elastic()
        @colorArea.popover({html: true, trigger: 'click'})
        @imageArea.popover({html: true, trigger: 'click', template: ''})
        # <div class="popover" role="tooltip"><div class="arrow"></div><div class="popover-content" style="box-sizing: border-box"></div></div>
        @addColorPopoverShown = false
        @addImagePopoverShown = false 

        @colorArea.on 'click', (e) =>
          @imageArea.popover('hide')

        @imageArea.on 'click', (e) =>
          @colorArea.popover('hide')

        @titleArea.on 'keydown', (e) =>
          if(e.keyCode == 13)
            e.preventDefault()
            @descriptionArea.focus()          

        @descriptionArea.on 'focus', (e) =>
          if($('#add').hasClass('contracted'))
            $('#add').removeClass('contracted')
            @descriptionArea.attr('rows', '1')
                  
        $('body').on 'click', (e) =>
          @resetAdd()

        $('#add').on 'click', (e) =>
          e.stopPropagation()

        @colorArea.on 'hover', (e) =>
          $('#add-color-popover').show()

        @descriptionArea.on 'shown.atwho', (e) =>
          @showingAtWho = true
        @descriptionArea.on 'hidden.atwho', (e) =>
          @showingAtWho = false

        @descriptionArea.atwho
          at: "@"
          data: @model.nodes.pluck('name')
          target: "#add-node-form"
        .atwho
          at: "#"
          data: @model.filterModel.getTags('node')
          target: "#add-node-form"
        
      resetAdd: () ->
        @imageArea.popover('hide')
        @colorArea.popover('hide')
        @descriptionArea.atwho 'destroy'
        $('div[id=atwho-container]').remove()
        $('#add').addClass('contracted')  
        @titleArea.val('')
        @descriptionArea.val('')

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
        @resetAdd()


      # moreInformation: ->
      #   @$el.find('.node-description').removeClass 'hide'
      #   @descriptionFocus = false
      #   $('.node-description').hover () =>
      #     @descriptionFocus = true
      #   , () => @descriptionFocus = false

      #   # TAB focues on description
      #   $('.node-input').on 'keydown', (e) =>
      #     keyCode = e.keyCode || e.which
      #     if keyCode == 9 # code for TAB
      #       e.preventDefault()
      #       @descriptionFocus = true
      #       @descriptionArea.focus()
      #       @descriptionFocus = false

      #   # Add atwho dropdowns to the description box
        

      # lessInformation: (e) ->
      #   # Don't hide info if focusing on it
      #   if !@descriptionFocus
      #     @$el.find('.node-description').addClass 'hide'
      #     @descriptionArea.atwho 'destroy'
      #     $('div[id=atwho-container]').remove() # removes all instances of the atwho-container

      # addNode: (e) ->
      #   if e? then e.preventDefault()

      #   attributes = {_docId: @model.nodes._docId}
      #   _.each $('#add-node-form').serializeArray(), (obj) ->
      #     attributes[obj.name] = obj.value

      #   attributes.selected = true

      #   node = new NodeModel attributes
      #   if node.isValid()
      #     @model.putNode node
      #     node.set "tags", twttr.txt.extractHashtags attributes.description

      #     $.when(node.save()).then =>
      #       # Create connections to mentioned nodes
      #       names = twttr.txt.extractMentions attributes.description

      #       for name in _.uniq names
      #         targetNode = @model.nodes.findWhere {name:name}
      #         if targetNode?
      #           connection = new @model.connections.model
      #               source: node.get('_id')
      #               target: targetNode.get('_id')
      #               _docId: @model.documentModel.get('_id')
      #               description: node.get('description')
      #           connection.save()
      #           @model.putConnection connection

      #     @$el[0].reset() # blanks out the form fields
      #     @descriptionFocus = false
      #   else
      #     $('input', @el).attr('placeholder', node.validate())
