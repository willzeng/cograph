define ['underscore', 'backbone'], (_, Backbone) ->
  class ObjectModel extends Backbone.Model
    idAttribute: '_id'

    defaults:
      name: ''
      description: ''
      url: ''
      color: 'white'
      tags: []
      _id: -1
      _docId: 0

    initialize: ->
      @socket.on @urlRoot()+":update", (objData) =>
        console.log "updating", @urlRoot(), " with ", objData
        if objData._id is this.get("_id").toString()
          @set objData

    isNew: ->
      @get(@idAttribute) < 0

    ignoredAttributes: ['selected', 'dim']

    sync: (method, model, options) ->
      options = options || {}
      options.data = @serialize()
      options.contentType = 'application/json'
      Backbone.sync.apply(this, [method, model, options])

    serialize: ->
      _.omit @clone().toJSON(), @ignoredAttributes
