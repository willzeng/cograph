define ['jquery', 'underscore', 'backbone', 'backbone-forms', 'list', 'backbone-forms-bootstrap', 'bootstrap', 'bb-modal',
 'text!templates/details_box.html', 'text!templates/edit_form.html', 'cs!models/NodeModel', 'cs!models/ConnectionModel',
 'bootstrap-color', 'atwho', 'twittertext', 'linkify', 'typeahead'],
  ($, _, Backbone, bbf, list, bbfb, Bootstrap, bbModal, detailsTemplate, editFormTemplate, NodeModel, ConnectionModel, ColorPicker, atwho, linkify, typeahead) ->
    class DetailsView extends Backbone.View
      el: $ 'body'

      events:
        'click .close' : 'closeDetail'
        'click #edit-node-button': 'editNodeConnection'
        'click #edit-connection-button': 'editNodeConnection'
        'submit #edit-node-form': 'saveNodeConnection'
        'click #archive-node-button': 'archiveObj'
        'click #archive-connection-button': 'archiveObj'
        'click #delete-button': 'deleteObj'
        'click #archive-button': 'archiveObj'
        'click #expand-node-button': 'expandNode'

      initialize: ->
        @graphView = @attributes.graphView

        @model.on 'conn:dblclicked', @openDetails, this
        @model.on 'node:dblclicked', @openDetails, this
        @model.on 'create:connection', @openAndEditConnection, this
        @model.on 'edit:conn', @openDetails, this
        @setupAtWho()

      openDetails: (nodeConnection) ->
        @currentNC = nodeConnection
        workspaceSpokes = @model.getSpokes nodeConnection
        @updateColor @model.defaultColors[nodeConnection.get('color')]
        nodeConnection.on "change:color", (nc) => @updateColor @model.defaultColors[nodeConnection.get('color')]
        isEditable = $('#add').length isnt 0

        if nodeConnection.isConnection
          title = """
          #{nodeConnection.source.get('name')}
            &nbsp;<i class="fa fa-long-arrow-right"></i>&nbsp;
          #{nodeConnection.get('name')}
            &nbsp;<i class="fa fa-long-arrow-right"></i>&nbsp;
          #{nodeConnection.target.get('name')}
          """
        else
          title = nodeConnection.get 'name'

        @detailsModal = new Backbone.BootstrapModal(
          content: _.template(detailsTemplate, {node:nodeConnection, spokes:workspaceSpokes, isEditable:isEditable})
          animate: false
          showFooter: false
          title: title
        ).open()

        $('.tag-link').on "click", (e) =>
          e.preventDefault()
          tag = $(e.currentTarget).attr('data-tag')
          @graphView.trigger 'tag:click', tag

      updateColor: (color) ->
        $('#details-container .panel-heading').css 'background', color

      closeDetail: () ->
        @detailsModal.close()
        @graphView.trigger "node:mouseout"

      openAndEditConnection: (conn) ->
        @currentNC = conn
        @openDetails conn
        @editNodeConnection()

      editNodeConnection: ->
        if($('#add-node-form').length > 0) #isEditable HACK
          nodeConnection = @currentNC
          @nodeConnectionForm = new Backbone.Form(
            model: nodeConnection
            template: _.template(editFormTemplate)
          ).on('name:blur url:blur tags:blur', (form, editor) ->
            form.fields[editor.key].validate()
          ).render()

          $('#details-container .panel-body').empty().append(@nodeConnectionForm.el)

          if nodeConnection.isNode then $('#details-container input[name=name]', @el).focus()

          colorOptions = colors:[(val for color, val of @model.defaultColors when !((color is 'grey') and nodeConnection.isNode))]
          $('.colorpalette').colorPalette(colorOptions).on 'selectColor', (e) =>
            colorValue = e.color
            nodeConnection.set 'color', _.invert(@model.defaultColors)[colorValue]
            nodeConnection.save()

      saveNodeConnection: (e) ->
        e.preventDefault()
        @nodeConnectionForm.commit()
        @nodeConnectionForm.model.save()

        if @nodeConnectionForm.model.isNode
          newConns = _.uniq @mentionedConns, (conn) ->
            conn.get 'target'

          for c in newConns
            c.save()
            @model.putConnection c

        @closeDetail()
        false

      archiveObj: ->
        if @currentNC.isNode
          @model.removeNode @currentNC
        else if @currentNC.isConnection
          @model.removeConnection @currentNC
        @closeDetail()

      # deletes the node or connections
      # and also removes it from the cached window.prefetch
      # that is used to quick load the whole cograph
      deleteObj: ->
        if @currentNC.isNode
          window.prefetch.nodes = _.filter window.prefetch.nodes, (n) =>
            @currentNC.get('_id') isnt n._id
          window.prefetch.connections = _.filter window.prefetch.connections, (c) =>
            @currentNC.get('_id') isnt c.source and @currentNC.get('_id') isnt c.target
          @model.deleteNode @currentNC, =>
            @model.nodes.map (n) -> n.fetch() #update NeighborCounts after deletion
        else if @currentNC.isConnection
          window.prefetch.connections = _.filter window.prefetch.connections, (n) =>
            @currentNC.get('_id') isnt n._id
          @model.deleteConnection @currentNC
        @closeDetail()

      expandNode: ->
        @currentNC.getNeighbors (neighbors) =>
          for node in neighbors
            newNode = new NodeModel node
            if @model.putNode newNode #this checks to see if the node has passed the filter
              newNode.getConnections @model.nodes, (connections) =>
                @model.putConnection new ConnectionModel conn for conn in connections

      setupAtWho: ->
        that = this
        @mentionedConns = [] # this stores newly mentioned conns

        connectionNameMatcher = () =>
          findMatches = (q, cb) =>
            $.get "/document/#{@model.documentModel.get('_id')}/connections", (connections) =>
              matches = _.uniq @findMatchingObjects(q, connections), (match) -> match.name
              cb _.map matches, (match) -> {value: match.name, type: 'connection'}

        typeaheadConfig =
              hint: false,
              highlight: true,
              minLength: 0,
              autoselect: true

        Backbone.Form.editors.ConnDropdown = Backbone.Form.editors.Text.extend
          render: () ->
            # Call the parent's render method
            Backbone.Form.editors.Text.prototype.render.call this
            # Then make the editor's element have a typeahead dropdown
            # for the document's connection names
            setTimeout () =>
              this.$el.typeahead typeaheadConfig,
                name: 'connection-names',
                source: connectionNameMatcher()
              this.$el.focus()
            , 10 # needs to wait for render before applying typeahead
            return this

        Backbone.Form.editors.AtWhoEditor = Backbone.Form.editors.TextArea.extend
          render: () ->
            # Call the parent's render method
            Backbone.Form.editors.TextArea.prototype.render.call this
            # Then make the editor's element have atwho.
            this.$el.atwho
              at: "+"
              data: _.filter that.model.nodes.pluck('name'), (name) => name isnt @model.get('name')
              target: ".modal-content"
            .atwho
              at: "#"
              data: that.model.filterModel.getTags('node')
              target: ".modal-content"

            # store inserted mentions
            @mentions = []
            this.$el.on "inserted.atwho", (event, item) =>
              insertedText = item.attr 'data-value'
              if insertedText[0] is "+"
                addedMention = that.model.nodes.findWhere({name:insertedText.slice(1)})
                @mentions.push addedMention
            return this

          # This parses the text to pull out mentions
          getValue: () ->
            str = this.$el.val()
            @model.set "tags", twttr.txt.extractHashtags(str)

            # only include mentions that still remain in the
            # description text
            @mentions = _.filter @mentions, (m) -> str.indexOf(m.get('name')) > 0

            # Create connections to mentioned nodes
            for targetNode in @mentions when targetNode.get('_id') isnt @model.get('_id')
              # get existing connections
              spokes = that.model.connections.filter (c) =>
                c.get('source') is @model.get('_id')
              neighbors = spokes.map (c) -> that.model.getTargetOf(c).get('name')

              # create a connection only if there is not already one
              if targetNode? and !(_.contains neighbors, name)
                connection = new ConnectionModel
                    source: @model.get('_id')
                    target: targetNode.get('_id')
                    _docId: that.model.documentModel.get('_id')
                    description: str

                that.mentionedConns.push connection

            this.$el.val()

      # Helper Methods
      findMatchingObjects: (query, allObjects) ->
        regex = new RegExp(query,'i')
        _.filter(allObjects, (object) -> regex.test(object.name))
