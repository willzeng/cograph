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
        @colorInput = $('#add-color-container')
        @imageInput = $('#add-image-container')

        @descriptionArea.elastic()
        @titleArea.elastic() 

        # Create color picker
        _.each(@model.defaultColors, (i, color) =>
          @colorInput.append('<div class="add-color-item color-circle" style="background-color:'+i+'" data-color="'+color+'"></div>')
        )

        $('.add-color-item').on 'click', (e) =>
          @colorArea.css('color', $(e.currentTarget).css('background-color'))
          @colorArea.data('color', $(e.currentTarget).data('color'))
          @colorInput.addClass('hidden')

        @colorArea.on 'click', (e) =>
          @imageInput.addClass('hidden')
          @colorInput.removeClass('hidden')

        @imageArea.on 'click', (e) =>
          @colorInput.addClass('hidden')
          @imageInput.toggleClass('hidden')
          @imageInput.focus()

        @titleArea.on 'keydown', (e) =>
          if e.keyCode == 13 # code for ENTER
            e.preventDefault()
            @descriptionArea.focus()          

        @descriptionArea.on 'focus', => @expandAdder()
                  
        $('body').on 'click', (e) => 
          if not $('#add').hasClass('contracted') then @resetAdd()
        $('#add').on 'click', (e) => e.stopPropagation()

        @colorArea.on 'hover', (e) => $('#add-color-popover').show()

        @descriptionArea.on 'shown.atwho', (e) => @showingAtWho = true
        @descriptionArea.on 'hidden.atwho', (e) => @showingAtWho = false

        # ENTER to create a node (w/o SHIFT)
        @descriptionArea.on 'keydown', (e) =>
          keyCode = e.keyCode || e.which
          # code for ENTER
          if keyCode == 13 and !@showingAtWho and !e.shiftKey
            $.when(@addNode()).then =>
              @expandAdder()

        # TAB from description to title
        @descriptionArea.on 'keydown', (e) =>
          keyCode = e.keyCode || e.which
          if keyCode == 9 # code for TAB
            e.preventDefault()
            @titleArea.focus()

        # TAB or ENTER from title to description
        @titleArea.on 'keydown', (e) =>
          keyCode = e.keyCode || e.which
          if keyCode == 9 or keyCode == 13 # code for TAB or ENTER
            e.preventDefault()
            @descriptionArea.focus()

      expandAdder: ->
        if $('#add').hasClass('contracted')
          $('#add').removeClass('contracted')
          @descriptionArea.attr('rows', '1')

          # add at-who autocompletion
          @descriptionArea.atwho
            at: "+"
            data: @model.nodes.pluck('name')
            target: "#add-node-form"
          .atwho
            at: "#"
            data: @model.filterModel.getTags('node')
            target: "#add-node-form"

          # setup inserted mentions store
          if @descriptionArea.val() is ""
            @mentions = []
          @descriptionArea.on "inserted.atwho", (event, item) =>
            insertedText = item.attr 'data-value'
            if insertedText[0] is "+"
              addedMention = @model.nodes.findWhere({name:insertedText.slice(1)})
              if addedMention? then @mentions.push addedMention

      resetAdd: () ->
        @imageInput.addClass('hidden')
        @colorInput.addClass('hidden')
        
        @descriptionArea.atwho 'destroy'
        $('div[id=atwho-container]').remove()
        @titleArea.val('')
        @descriptionArea.val('') 
        @descriptionArea.trigger('change')
        @titleArea.trigger('change')   
        $('#add').addClass('contracted')  

      addNode: (e) ->
        if e? then e.preventDefault()

        attributes = {_docId: @model.nodes._docId}
        _.each $('#add-node-form').serializeArray(), (obj) ->
          attributes[obj.name] = obj.value

        attributes.selected = true
        attributes.color = @colorArea.data('color')
        attributes.image = @imageInput.val()
        if(attributes['name'] == "" && attributes['description'] != "")
          attributes['name'] = attributes['description'].substring(0,25)
        if(attributes['description'].length > 25)
          attributes['name'] += "...";
        node = new NodeModel attributes
        if node.isValid()
          @model.putNode node
          node.set "tags", twttr.txt.extractHashtags attributes.description

          $.when(node.save()).then =>
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

            @resetAdd()
        else
          $('input', @el).attr('placeholder', node.validate())
