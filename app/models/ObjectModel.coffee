define ['underscore', 'backbone'], (_, Backbone) ->
  class ObjectModel extends Backbone.Model
    idAttribute: '_id'

    defaults:
      name: ''
      description: ''
      url: ''
      color: 'grey'
      tags: []
      _id: -1
      _docId: 0

    isNew: ->
      @get(@idAttribute) < 0

    ignoredAttributes: ['selected', 'dim']

    sync: (method, model, options) ->
      options = options || {}
      options.data = JSON.stringify(@serialize())
      options.contentType = 'application/json'
      Backbone.sync.apply(this, [method, model, options])

    serialize: ->
      _.omit @clone().toJSON(), @ignoredAttributes
