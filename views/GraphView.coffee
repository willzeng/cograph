define ['jquery', 'underscore', 'backbone', 'text!node.html'], ($, _, Backbone, nodeTemplate) ->

  GraphView = Backbone.View.extend

    el: $ '#main-area'

    initialize: ->
      @model.nodes.on 'add', @update, this

    update: (node) ->
      $(@el).append _.template(nodeTemplate, node.attributes)

    render: ->
      $(@el).append '<h2>More Header</h2>'
