define ['jquery', 'underscore', 'backbone', 'backbone-forms', 'list', 'backbone-forms-bootstrap', 'bootstrap',
 'text!templates/details_box.html', 'text!templates/edit_form.html', 'cs!models/NodeModel', 'cs!models/ConnectionModel',
 'bootstrap-color', 'atwho', 'twittertext', 'linkify', 'typeahead'],
  ($, _, Backbone, bbf, list, bbfb, Bootstrap, detailsTemplate, editFormTemplate, NodeModel, ConnectionModel, ColorPicker, atwho, linkify, typeahead) ->
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
        @loadBBModal()
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

      loadBBModal: ->
        ###*
        Bootstrap Modal wrapper for use with Backbone.

        Takes care of instantiation, manages multiple modals,
        adds several options and removes the element from the DOM when closed

        @author Charles Davison <charlie@powmedia.co.uk>

        Events:
        shown: Fired when the modal has finished animating in
        hidden: Fired when the modal has finished animating out
        cancel: The user dismissed the modal
        ok: The user clicked OK
        ###
        (($, _, Backbone) ->
          
          #Set custom template settings
          _interpolateBackup = _.templateSettings
          _.templateSettings =
            interpolate: /\{\{(.+?)\}\}/g
            evaluate: /<%([\s\S]+?)%>/g

          template = _.template("""
            <div class=\"modal-dialog\">
              <div class=\"modal-content\">
                <% if (title) { %>
                <div class=\"modal-header\">
                  <% if (allowCancel) { %>
                  <a class=\"close\">&times;</a>
                  <% } %>
                  <h4>{{title}}</h4>
                </div>
                <% } %>
              <div class=\"modal-body\">{{content}}</div>
              <% if (showFooter) { %>
                <div class=\"modal-footer\">
                  <% if (allowCancel) { %>
                    <% if (cancelText) { %>
                      <a href=\"#\" class=\"btn cancel\">{{cancelText}}</a>
                    <% } %>
                  <% } %>
                  <a href=\"#\" class=\"btn ok btn-primary\">{{okText}}</a>
                </div>
              <% } %>
              </div>
            </div>
            """)
          
          #Reset to users' template settings
          _.templateSettings = _interpolateBackup
          Modal = Backbone.View.extend(
            className: "modal"
            events:
              "click .close": (event) ->
                event.preventDefault()
                @trigger "cancel"
                @options.content.trigger "cancel", this  if @options.content and @options.content.trigger

              "click .cancel": (event) ->
                event.preventDefault()
                @trigger "cancel"
                @options.content.trigger "cancel", this  if @options.content and @options.content.trigger

              "click .ok": (event) ->
                event.preventDefault()
                @trigger "ok"
                @options.content.trigger "ok", this  if @options.content and @options.content.trigger
                @close()  if @options.okCloses

              keypress: (event) ->
                if @options.enterTriggersOk and event.which is 13
                  event.preventDefault()
                  @trigger "ok"
                  @options.content.trigger "ok", this  if @options.content and @options.content.trigger
                  @close()  if @options.okCloses
            
            ###*
            Creates an instance of a Bootstrap Modal
            ###
            initialize: (options) ->
              @options = _.extend(
                title: null
                okText: "OK"
                focusOk: true
                okCloses: true
                cancelText: "Cancel"
                showFooter: true
                allowCancel: true
                escape: true
                animate: false
                template: template
                enterTriggersOk: false
              , options)
            
            ###*
            Creates the DOM element
            ###
            render: ->
              $el = @$el
              options = @options
              content = options.content
              
              #Create the modal container
              $el.html options.template(options)
              $content = @$content = $el.find(".modal-body")
              
              #Insert the main content if it's a view
              if content and content.$el
                content.render()
                $el.find(".modal-body").html content.$el
              $el.addClass "fade"  if options.animate
              @isRendered = true
              this

            ###*
            Renders and shows the modal            
            @param {Function} [cb]     Optional callback that runs only when OK is pressed.
            ###
            open: (cb) ->
              @render()  unless @isRendered
              self = this
              $el = @$el
              
              #Create it
              $el.modal _.extend(
                keyboard: @options.allowCancel
                backdrop: (if @options.allowCancel then true else "static")
              , @options.modalOptions)
              
              #Focus OK button
              $el.one "shown.bs.modal", ->
                $el.find(".btn.ok").focus()  if self.options.focusOk
                self.options.content.trigger "shown", self  if self.options.content and self.options.content.trigger
                self.trigger "shown"

              #Adjust the modal and backdrop z-index; for dealing with multiple modals
              numModals = Modal.count
              $backdrop = $(".modal-backdrop:eq(" + numModals + ")")
              backdropIndex = parseInt($backdrop.css("z-index"), 10)
              elIndex = parseInt($backdrop.css("z-index"), 10)
              $backdrop.css "z-index", backdropIndex + numModals
              @$el.css "z-index", elIndex + numModals
              if @options.allowCancel
                $backdrop.one "click", ->
                  self.options.content.trigger "cancel", self  if self.options.content and self.options.content.trigger
                  self.trigger "cancel"

                $(document).one "keyup.dismiss.modal", (e) ->
                  e.which is 27 and self.trigger("cancel")
                  e.which is 27 and self.options.content.trigger("shown", self)  if self.options.content and self.options.content.trigger

              @on "cancel", ->
                self.close()

              Modal.count++
              
              #Run callback on OK if provided
              self.on "ok", cb  if cb
              this
            
            ###*
            Closes the modal
            ###
            close: ->
              self = this
              $el = @$el
              
              #Check if the modal should stay open
              if @_preventClose
                @_preventClose = false
                return
              $el.one "hidden.bs.modal", onHidden = (e) ->
                
                # Ignore events propagated from interior objects, like bootstrap tooltips
                return $el.one("hidden", onHidden)  if e.target isnt e.currentTarget
                self.remove()
                self.options.content.trigger "hidden", self  if self.options.content and self.options.content.trigger
                self.trigger "hidden"
                return

              $el.modal "hide"
              Modal.count--
              return
            
            ###*
            Stop the modal from closing.
            Can be called from within a 'close' or 'ok' event listener.
            ###
            preventClose: ->
              @_preventClose = true
              return
          ,
            
            #STATICS            
            #The number of modals on display
            count: 0
          )
          
          #Regular; add to Backbone.Bootstrap.Modal
          #else
          Backbone.BootstrapModal = Modal
        ) jQuery, _, Backbone
