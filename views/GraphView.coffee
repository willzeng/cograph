define [], () ->

  class GraphView extends Backbone.View

    init: (instances) ->
      @model = instances['js/GraphModel']
      @model.on "change", @update

    update: =>
      container = $('body')
      for node in @model.getNodes()
        $("<div>#{node}</div>").appendTo container

