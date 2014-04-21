define ['jquery', 'backbone'], ($, Backbone) ->

  GraphView = Backbone.View.extend

    el: $ '#main-area'

    initialize: ->
      @model.on 'change', @update, this

    update: ->
      $(@el).html("") #clears html
      for node in @model.getNodes()
        $("<div>#{node}</div>").appendTo $(@el)

    render: ->
      $(@el).append '<h2>More Header</h2>'
