define ['backbone'], (Backbone) ->
  class DocumentModel extends Backbone.Model
    defaults:
      name: ''
      _id: 'DefaultDoc'
