define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  GraphView = Backbone.View.extend

    el: $ '#main-area'

    initialize: ->
      @model.nodes.on 'add', @update, this

    update: (node) ->
      $("<div>#{node.get('name')}</div>").appendTo $(@el)

    render: ->
      $(@el).append '<h2>More Header</h2>'
