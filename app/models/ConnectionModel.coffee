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

    schema:
      name: 'Text'
      url: 'Text'
      description: 'TextArea'
      tags: { type: 'List', itemType: 'Text' }
