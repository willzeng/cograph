define ['backbone'], (Backbone) ->

  class NodeModel extends Backbone.Model
    defaults:
      name: ''
      tags: []
      description: ''

    schema:
      name: 'Text',
      description: 'TextArea'
      tags: { type: 'List', itemType: 'Text' }
