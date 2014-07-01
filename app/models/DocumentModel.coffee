define ['backbone'], (Backbone) ->
  class DocumentModel extends Backbone.Model
    urlRoot: 'documents'
    idAttribute: '_id'

    defaults:
      name: 'Untitled'
      _id: -1

    isNew: ->
      @get(@idAttribute) < 0
