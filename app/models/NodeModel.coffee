define ['jquery', 'underscore', 'backbone', 'cs!models/ObjectModel', 'b-iobind', 'b-iosync', 'socket-io'],
($, _, Backbone, ObjectModel, iobind, iosync, io) ->
  class NodeModel extends ObjectModel
    urlRoot: -> "node"
    ajaxURL: -> "/documents/#{@get('_docId')}/nodes"
    noIoBind: false
    socket: io.connect('')

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
        validators: [type: 'regexp', regexp: /^\w+$/]

    validate: ->
      if !@get('name')
        return 'Your node must have a name.'
      if !(typeof @get('_id') is 'number')
        return '_id must be a number.'

    parse: (resp, options) ->
      if resp._id then resp._id = parseInt(resp._id, 10)
      resp

    getNeighbors: (callback) =>
      @sync 'read', this,
        url: @ajaxURL() + "/neighbors/"
        success: (results) =>
          callback (@parse result for result in results)

    getSpokes: (callback) ->
      this.sync 'read', this,
        url: @ajaxURL() + "/spokes/"
        success: (results) ->
          callback results

    getConnections: (nodes, callback) ->
      nodeIds = (n.id for n in nodes)
      data = {nodeIds: nodeIds}
      $.post @ajaxURL()+"/get_connections/", data, (results) ->
        callback results
