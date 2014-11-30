define ['jquery', 'underscore', 'backbone', 'cs!models/WorkspaceModel', 'cs!models/NodeModel',
'atwho', 'twittertext', 'jquery-autosize'],
  ($, _, Backbone, WorkspaceModel, NodeModel, atwho, twittertext, autosize) ->
    class AddNodeView extends Backbone.View
      el: $ '#add-node-form'
      createdThisSession: 0

      events: 
        'submit' : 'addNode'

      initialize: ->
        @descriptionArea = $('#add-description')
        @titleArea = $('#add-title')
        @colorArea = $('#add-color')
        @imageArea = $('#add-image')
        @colorInput = $('#add-color-container')
        @imageInput = $('#add-image-container')

        @descriptionArea.autosize()

        # Create color picker
        _.each @model.defaultColors, (i, color) =>
          @colorInput.append('<div class="add-color-item color-circle" style="background-color:'+i+'" data-color="'+color+'"></div>')
        @colorArea.css('color', @model.defaultColors["defaultHex"])
        @colorArea.data('color', @model.defaultColors["defaultHex"])


        $('.add-color-item').on 'click', (e) =>
          @colorArea.css('color', $(e.currentTarget).css('background-color'))
          @colorArea.data('color', $(e.currentTarget).data('color'))
          @colorInput.addClass('hidden')

        @colorArea.on 'click', (e) =>
          if !@colorInput.hasClass('hidden')
            @colorInput.addClass('hidden')
          else
            @imageInput.addClass('hidden')
            @colorInput.removeClass('hidden')

        @imageArea.on 'click', (e) =>
          if !@imageInput.hasClass('hidden')
            @imageInput.addClass('hidden')
          else
            @colorInput.addClass('hidden')
            @imageInput.toggleClass('hidden')
            @imageInput.focus()
         
        @titleArea.on 'focus', => @expandAdder()
                  
        $('body').on 'click', (e) => 
          if not $('#add').hasClass('contracted') then @resetAdd()
        $('#add-node-form').on 'click', (e) => e.stopPropagation()

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
              @titleArea.focus()
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
        $('#atwho-container').remove()
        @titleArea.val('')
        @imageInput.val('')
        @descriptionArea.val('') 
        @descriptionArea.trigger('autosize.resize')
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
          # stage the new node in the staging area
          # if it is not connected to anything
          # if @mentions.length is 0
          #   node.fixed = true
          #   [node.x, node.y] = @findUnoccupiedStage()

          node.set "tags", twttr.txt.extractHashtags attributes.description

          @mentions = _.filter @mentions, (m) -> attributes.description.indexOf(m.get('name')) > 0
          uniqMentions = _.uniq @mentions, null, (n) -> n.get('name')
          node.set "neighborCount", uniqMentions.length

          @model.putNode node

          $.when(node.save()).then =>
            @model.trigger 'saved:node'

            # Create connections to mentioned nodes
            for targetNode in uniqMentions
              if targetNode?
                connection = new @model.connections.model
                    source: node.get('_id')
                    target: targetNode.get('_id')
                    _docId: @model.documentModel.get('_id')
                    description: node.get('description')
                $.when(connection.save()).then ->
                  # update neighbor counts
                  node.fetch()
                  targetNode.fetch()
                @model.putConnection connection

          @resetAdd()
        else
          $('input', @el).attr('placeholder', node.validate())

      findUnoccupiedStage: ->
        @createdThisSession = @createdThisSession+1
        x = $(window).width()-150
        posts = ({x:x,y:180+70*n} for n in [0..@createdThisSession-1])

        distance = (x,y,px,py) ->
          Math.sqrt (x-px)*(x-px)+(y-py)*(y-py)

        isClear = (px,py) =>
          nodes = @model.nodes.models
          distances = _.map nodes, (n) -> distance px, py, n.x, n.y
          distances = distances.sort()
          distances[0] > 60

        availablePosts = _.filter posts, (p) -> isClear p.x, p.y
        if availablePosts.length < 1 then availablePosts[0] = posts[posts.length-1]
        [availablePosts[0].x,availablePosts[0].y]
