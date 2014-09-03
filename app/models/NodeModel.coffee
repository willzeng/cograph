define ['jquery', 'underscore', 'backbone', 'cs!models/ObjectModel', 'b-iobind', 'b-iosync', 'socket-io'],
($, _, Backbone, ObjectModel, iobind, iosync, io) ->
  class NodeModel extends ObjectModel
    urlRoot: -> "node"
    ajaxURL: -> "/document/#{@get('_docId')}/nodes/"+@get('_id')
    noIoBind: false
    socket: io.connect('')

    defaults:
      name: ''
      description: ''
      url: ''
      color: 'black'
      tags: []
      _id: -1
      _docId: 0
      neighborCount: 0

    schema:
      name:
        type: 'Text'
        validators: ['required']
      url:
        type: 'Text'
        validators: [type: 'regexp', regexp: /((www|http|https)([^\s]+))|([a-z0-9!#$%&'+\/=?^_`{|}~-]+(?:.[a-z0-9!#$%&'+\/=?^_`{|}~-]+)*@(?:a-z0-9?.)+a-z0-9?)/ ]
      description:
        type: 'AtWhoEditor'
      image: 
        type: 'Text'
        title: 'Image (url to an image)'
        validators: [type: 'regexp', regexp: /((www|http|https)([^\s]+))|([a-z0-9!#$%&'+\/=?^_`{|}~-]+(?:.[a-z0-9!#$%&'+\/=?^_`{|}~-]+)*@(?:a-z0-9?.)+a-z0-9?)/ ]

    validate: ->
      if !@get('name')
        return 'Your node must have a name.'
      if !(typeof @get('_id') is 'number')
        return '_id must be a number.'

    getNeighbors: (callback) =>
      $.get @ajaxURL()+"/neighbors/", (results) =>
        callback (@parse result for result in results)

    getSpokes: (callback) ->
      $.get @ajaxURL()+"/spokes/", (results) ->
        callback results

    getConnections: (nodeCollection, callback) ->
      nodeIds = nodeCollection.pluck '_id'
      data = {nodeIds: nodeIds}
      $.post @ajaxURL()+"/get_connections/", data, (results) ->
        callback results
