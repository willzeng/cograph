define ['backbone'], (Backbone, GraphModel) ->
  class ConnectionModel extends Backbone.Model
    url: 'connection'
    idAttribute: '_id'

    isNew: ->
      @get(@idAttribute) < 0

    defaults:
      name: ''
      description: ''
      url: ''
      source: undefined
      target: undefined
      color: 'grey'
      tags: []
      _id: -1

    schema:
      name: 'Text'
      url: 'Text'
      description: 'TextArea'
      tags: { type: 'List', itemType: 'Text' }

    serialize: ->
      json = _.omit @clone().toJSON(), @ignoredAttributes
      json

    validate: ->
      if !(typeof @get('source') is 'number' and typeof @get('target') is 'number')
        '_id must be a number.'

    ignoredAttributes: ['selected', 'dim', 'tags']

    sync: (method, model, options) ->
      options = options || {}
      options.data = JSON.stringify(@serialize())
      options.contentType = 'application/json'
      Backbone.sync.apply(this, [method, model, options])
