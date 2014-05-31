define ['backbone', 'cs!models/ObjectModel'], (Backbone, ObjectModel) ->
  class ConnectionModel extends ObjectModel
    url: 'connection'

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
