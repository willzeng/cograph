define ['jquery', 'underscore', 'backbone', 'cs!models/ObjectModel'], ($, _, Backbone, ObjectModel) ->
  class NodeModel extends ObjectModel
    urlRoot: -> "/documents/#{@get('_docId')}/nodes"

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
        url: @url() + "/neighbors/"
        success: (results) =>
          callback (@parse result for result in results)

    getSpokes: (callback) ->
      this.sync 'read', this,
        url: @url() + "/spokes/"
        success: (results) ->
          callback results

    getConnections: (nodes, callback) ->
      nodeIds = (n.id for n in nodes)
      data = {nodeIds: nodeIds}
      $.post @url()+"/get_connections/", data, (results) ->
        callback results
