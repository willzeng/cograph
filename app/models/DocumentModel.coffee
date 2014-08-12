define ['backbone', 'b-iobind', 'b-iosync', 'socket-io'], (Backbone, iobind, iosync, io) ->
  class DocumentModel extends Backbone.Model
    urlRoot: 'document'
    idAttribute: '_id'
    noIoBind: false
    socket: io.connect('')

    defaults:
      name: 'Untitled'
      _id: -1
      workspaces: []

    initialize: ->
      @socket.on @urlRoot+":update", (objData) =>
        @set objData

    isNew: ->
      @get(@idAttribute) < 0

    serialize: ->
      if @get('workspaces')[0]?
        {name:@get('name'), _id:@get('_id'), workspaces:@get('workspaces')}
      else
        {name:@get('name'), _id:@get('_id')}

    sync: (method, model, options) ->
      options = options || {}
      options.data = @serialize()
      options.contentType = 'application/json'
      Backbone.sync.apply(this, [method, model, options])

    # Getter methods
    getNodeNames: (cb) ->
      $.get @url() + '/nodes/names', {}, (names) =>
        cb names

    getTagNames: (cb) ->
      $.get @url() + '/tags', {}, (tagNames) =>
        cb tagNames

    getNodeByName: (name, cb) ->
      $.get @url() + '/getNodeByName', {name: name}, (node) =>
        cb node

    getNodesByTag: (tag, cb) ->
      $.get @url() + '/getNodesByTag', {tag: tag}, (nodes) =>
        cb nodes

    getAnalytics: (cb) ->
      $.get @url() + '/analytics', {}, (results) ->
        cb results
