define ['backbone'], (Backbone) ->
  class ConnectionModel extends Backbone.Model
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

    ignoredAttributes: ['dim', 'selected']

    serialize: ->
      json = _.omit @clone().toJSON(), @ignoredAttributes
      json.source = @get('source').get('_id')
      json.target = @get('target').get('_id')
      json
