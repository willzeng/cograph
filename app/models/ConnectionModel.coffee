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
      name: {type:'Text', title:"Connection Type e.g. 'relates to'"}
      url: 'Text'
      description:
        type: 'AtWhoEditor'
      image: 
        type: 'Text'
        title: 'Image (url to an image)'
        validators: [type: 'regexp', regexp: /((www|http|https)([^\s]+))|([a-z0-9!#$%&'+\/=?^_`{|}~-]+(?:.[a-z0-9!#$%&'+\/=?^_`{|}~-]+)*@(?:a-z0-9?.)+a-z0-9?)/ ]

    ignoredAttributes: ['selected', 'dim']

    validate: ->
      if !(typeof @get('source') is 'number' and typeof @get('target') is 'number')
        '_id of source and target must be a number.'
      if !(typeof @get('_id') is 'number')
        '_id of connection must be a number.'

    serialize: ->
      lessIgnored = _.omit @clone().toJSON(), @ignoredAttributes
      if @get('tags').length is 0
        _.omit lessIgnored, ['tags']
      else
        lessIgnored
