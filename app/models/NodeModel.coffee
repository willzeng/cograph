define ['underscore', 'backbone'], (_, Backbone) ->
  class NodeModel extends Backbone.Model
    url: 'node'
    idAttribute: '_id'

    isNew: ->
      @get(@idAttribute) < 0

    defaults:
      name: ''
      tags: []
      description: ''
      url: ''
      size: ''
      color: ''
      _id: -1

    schema:
      name:
        type: 'Text'
        validators: ['required']
      url:
        type: 'Text'
        validators: [type: 'regexp', regexp: /((www|http|https)([^\s]+))|([a-z0-9!#$%&'+\/=?^_`{|}~-]+(?:.[a-z0-9!#$%&'+\/=?^_`{|}~-]+)*@(?:a-z0-9?.)+a-z0-9?)/ ]
      description:
        type: 'TextArea'
      tags:
        type: 'List'
        itemType: 'Text'

    ignoredAttributes: ['selected', 'dim', 'tags']

    validate: ->
      if !@get('name')
        'Your node must have a name.'
      if !(typeof @get('_id') is 'number')
        '_id must be a number.'

    serialize: ->
      _.omit @clone().toJSON(), @ignoredAttributes

    parse: (resp, options) ->
      if resp._id then resp._id = parseInt(resp._id, 10)
      resp

    sync: (method, model, options) ->
      options = options || {}
      options.data = JSON.stringify(@serialize())
      options.contentType = 'application/json'
      Backbone.sync.apply(this, [method, model, options])
