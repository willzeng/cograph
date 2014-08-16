define ['jquery', 'backbone', 'cs!models/NodeModel','cs!models/ConnectionModel',
  'cs!models/FilterModel', 'cs!models/DocumentModel', 'socket-io'],
  ($, Backbone, NodeModel, ConnectionModel, FilterModel, DocumentModel, io) ->
    class ObjectCollection extends Backbone.Collection
      _docId: 0
      socket: io.connect("")

      initialize: ->
        @socket.on @url()+":create", (objData) =>
          @add new @model objData, {parse:true}

        @socket.on @url()+":update", (objData) =>
          objData._id = parseInt(objData._id)
          id = objData._id
          @findWhere({_id:id}).set objData

        @socket.on @url()+":delete", (objData) =>
          @remove new @model objData

      # Extend sync to pass through the current document on read
      sync: (method, model, options) ->
        if method is "read" then options = _.extend options, {attrs:{_docId:@_docId}}
        Backbone.sync method, model, options

    class ConnectionCollection extends ObjectCollection
      model: ConnectionModel
      url: -> "connections"

    class NodeCollection extends ObjectCollection
      model: NodeModel
      url: -> "nodes"

    class WorkspaceModel extends Backbone.Model
      socket: io.connect("")
      urlRoot: -> "workspace"
      _id: 0

      selectedColor: '#3498db'

      defaultColors:
          black:'#000'
          grey:'#ccc'
          red:'#F56545'
          yellow:'#FFBB22'
          green: '#BBE535'
          # cyan: '#77DDBB'
          blue: '#66CCDD'

      initialize: ->
        @socket = io.connect('')

        @nodes = new NodeCollection()
        @connections = new ConnectionCollection()

        @filterModel = new FilterModel()
        @nodes.on "change:tags", @updateFilter, this

        @documentModel = new DocumentModel()

      updateFilter: (node) ->
        @filterModel.set 'initial_tags', _.union(@filterModel.get('node_tags'), node.get('tags'))
        @filterModel.addNodeTags node.get('tags')

      setDocument: (doc) ->
        @documentModel = doc
        @nodes._docId = doc.id
        @connections._docId = doc.id
        @trigger "document:change"
        @socket.emit 'open:document', doc.attributes
        @connections.reset()
        $.when(@nodes.fetch()).then =>
          @connections.fetch()

      getDocument: ->
        @documentModel

      filter: =>
        nodesToRemove = @nodes.filter (node) =>
          !(@filterModel.passes node)
        @removeNode node for node in nodesToRemove

      # if called with nm, force:true the a node will be forced
      # through the filter, adding its tags to the filterModel
      putNode: (nodeModel, options) ->
        @nodes.add nodeModel
        nodeModel

      putNodeFromData: (data, options) ->
        node = new NodeModel data
        @putNode node, options

      putConnection: (connectionModel) ->
        @connections.add connectionModel

      newConnectionCreated: (conn) ->
        @trigger 'create:connection', conn

      removeNode: (node) ->
        @connections.remove @connections.where {'source': node.get('_id')}
        @connections.remove @connections.where {'target': node.get('_id')}
        @nodes.remove node

      removeConnection: (model) ->
        @connections.remove model

      deleteNode: (model) ->
        @removeNode model
        model.destroy()

      deleteConnection: (model) ->
        @removeConnection model
        model.destroy()

      deSelect: (model, silent) ->
        if silent
          model.set {selected:false}, {silent:true}
        else
          model.set 'selected', false

      select: (model) ->
        @nodes.each (d) => @deSelect d, true
        @connections.each (d) => @deSelect d, true
        model.set 'selected', true

      getSourceOf: (connection) ->
        @nodes.findWhere _id: connection.get('source')

      getTargetOf: (connection) ->
        @nodes.findWhere _id: connection.get('target')

      highlight: (nodesToHL, connectionsToHL) ->
        @nodes.each (d) ->
          d.set 'dim', true
        _.each nodesToHL, (d) ->
          d.set 'dim', false
        @connections.each (d) ->
          d.set 'dim', true
        _.each connectionsToHL, (d) ->
          d.set 'dim', false
        @nodes.trigger "change"

      dehighlight: () ->
        @connections.each (d) ->
          d.set 'dim', false
        @nodes.each (d) ->
          d.set 'dim', false
        @nodes.trigger "change"

      getSpokes: (node) ->
        (@connections.where {'source': node.get('_id')}).concat @connections.where {'target': node.get('_id')}

      getFilter: () ->
        @filterModel

      getNodeNames: (cb) ->
        @documentModel.getNodeNames(cb)

      getTagNames: (cb) ->
        @documentModel.getTagNames(cb)

      getNodeByName: (name, cb) ->
        @documentModel.getNodeByName(name, cb)

      getNodesByTag: (tag, cb) ->
        @documentModel.getNodesByTag(tag, cb)

      # Syncing Workspaces
      sync: (method, model, options) ->
        options = options || {}
        options.data = @serialize()
        options.contentType = 'application/json'
        Backbone.sync.apply(this, [method, model, options])

      serialize: ->
        nodes = @nodes.pluck "_id"
        connIds = @connections.pluck "_id"
        docId = @getDocument().get "_id"
        {nodes:nodes, connections:connIds, nodeTags:@filterModel.get('node_tags'), _id: this._id, _docId:docId}

      getWorkspace: (callback) ->
        @sync "read", this,
          success: callback

      deleteWorkspace: (id, callback) ->
        @socket.emit "workspace:destroy", id
        callback id
