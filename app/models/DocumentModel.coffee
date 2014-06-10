define ['backbone'], (Backbone) ->
  class DocumentModel extends Backbone.Model
    urlRoot: 'document'
    idAttribute: '_id'

    defaults:
      name: ''
      _id: -1

    isNew: ->
      @id < 0
