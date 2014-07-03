define ['backbone', 'b-iobind', 'b-iosync', 'socket-io'], (Backbone, iobind, iosync, io) ->
  class DocumentModel extends Backbone.Model
    urlRoot: 'documents'
    idAttribute: '_id'
    noIoBind: false
    socket: io.connect('')

    defaults:
      name: 'Untitled'
      _id: -1

    isNew: ->
      @get(@idAttribute) < 0

    getNodeNames: (cb) ->
      $.get @url() + '/nodes/names', {}, (names) =>
        cb names

    getTagNames: (cb) ->
      $.get @url() + '/tags', {}, (tagNames) =>
        cb tagNames

    getNodeByName: (name, cb) ->
      $.get @url() + '/getNodeByName', {name: name}, (node) =>
        cb node

    getNodesByTag: (tag, cb) ->
      $.get @url() + '/getNodesByTag', {tag: tag}, (nodes) =>
        cb nodes
