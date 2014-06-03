define ['underscore', 'backbone', 'cs!models/ObjectModel'], (_, Backbone, ObjectModel) ->
  class NodeModel extends ObjectModel
    url: 'node'
    
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

    validate: ->
      if !@get('name')
        return 'Your node must have a name.'
      if !(typeof @get('_id') is 'number')
        return '_id must be a number.'

    parse: (resp, options) ->
      if resp._id then resp._id = parseInt(resp._id, 10)
      resp
