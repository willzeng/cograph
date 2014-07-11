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

    ignoredAttributes: ['selected', 'dim']

    validate: ->
      if !(typeof @get('source') is 'number' and typeof @get('target') is 'number')
        '_id of source and target must be a number.'
      if !(typeof @get('_id') is 'number')
        '_id of connection must be a number.'

    serialize: ->
      removedKeys = @ignoredAttributes
      if @get('tags').length is 0 then removedKeys.push('tags')
      _.omit @clone().toJSON(), removedKeys
