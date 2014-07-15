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
      tagToColor: {}  # This dictionary automatically maps certain tags to colors
                      # on the client side

    isNew: ->
      @get(@idAttribute) < 0

    ignoredAttributes: ['selected', 'dim']

    parse: (resp, options) ->
      if resp.tags and !($.isEmptyObject(@tagToColor))
        for tag in resp.tags
          resp.color = @tagToColor[tag]
      if resp._id then resp._id = parseInt(resp._id, 10)
      resp

    sync: (method, model, options) ->
      options = options || {}
      options.data = @serialize()
      options.contentType = 'application/json'
      Backbone.sync.apply(this, [method, model, options])

    serialize: ->
      _.omit @clone().toJSON(), @ignoredAttributes
