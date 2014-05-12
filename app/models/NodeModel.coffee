define ['backbone'], (Backbone) ->

  class NodeModel extends Backbone.Model
    defaults:
      name: ''
      tags: []
      description: ''
      url: ''
      size: ''
      color: ''

    schema:
      name: 'Text'
      url: 'Text'
      description: 'TextArea'
      tags: { type: 'List', itemType: 'Text' }
     
