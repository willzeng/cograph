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
      # json.source = @get('source').get('_id')
      # json.target = @get('target').get('_id')
      json

    ignoredAttributes: ['selected', 'dim', 'tags']

    sync: (method, model, options) ->
      options = options || {}
      options.data = JSON.stringify(@serialize())
      options.contentType = 'application/json'
      Backbone.sync.apply(this, [method, model, options])
