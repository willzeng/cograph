define ['underscore', 'backbone'], (_, Backbone) ->
  class ObjectModel extends Backbone.Model
    idAttribute: '_id'

    isNew: ->
      @get(@idAttribute) < 0

    ignoredAttributes: ['selected', 'dim', 'tags']

    sync: (method, model, options) ->
      options = options || {}
      options.data = JSON.stringify(@serialize())
      options.contentType = 'application/json'
      Backbone.sync.apply(this, [method, model, options])

    serialize: ->
      json = _.omit @clone().toJSON(), @ignoredAttributes
      json
