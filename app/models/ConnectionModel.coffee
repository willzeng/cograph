define ['backbone', 'cs!models/ObjectModel', 'b-iobind', 'b-iosync', 'socket-io'],
(Backbone, ObjectModel, iobind, iosync, io) ->
  class ConnectionModel extends ObjectModel
    urlRoot: -> "connection"
    noIoBind: false
    socket: io.connect('')

    defaults:
      name: ''
      description: ''
      url: ''
      source: undefined
      target: undefined
      color: 'white'
      tags: []
      _id: -1
      _docId: 0

    schema:
      name: 'Text'
      url: 'Text'
      description: 'TextArea'
      tags: { type: 'List', itemType: 'Text' }

    ignoredAttributes: ['selected', 'dim', 'tags']

    serialize: ->
      json = _.omit @clone().toJSON(), @ignoredAttributes
      json

    validate: ->
      if !(typeof @get('source') is 'number' and typeof @get('target') is 'number')
        '_id must be a number.'
