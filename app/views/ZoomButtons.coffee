define ['jquery', 'underscore', 'backbone'],
  ($, _, Backbone) ->
    class ZoomButtons extends Backbone.View
      el: $ '#graph'
      
      events:
        'click #zoom-in-button': 'scaleZoom'
        'click #zoom-out-button': 'scaleZoom'

      initialize: ->
        @zoom = @attributes.zoom
        @workspace = @attributes.workspace

      scaleZoom: (event) ->
        if $(event.currentTarget).attr('id') is 'zoom-in-button'
          scale = 1.3
        else if $(event.currentTarget).attr('id') is 'zoom-out-button'
          scale = 1/1.3
        else
          scale = 1

        #find the current view and viewport settings
        center = [$(@el).width()/2, $(@el).height()/2]
        translate = @zoom.translate()
        view = {x: translate[0], y: translate[1]}

        #set the new scale factor
        newScale = @zoom.scale()*scale

        #calculate offset to zoom in center
        translate_orig = [(center[0] - view.x) / @zoom.scale(), (center[1] - view.y) / @zoom.scale()]
        diff = [translate_orig[0] * newScale + view.x, translate_orig[1] * newScale + view.y]
        view.x += center[0] - diff[0]
        view.y += center[1] - diff[1]

        #update zoom values
        @zoom.translate([view.x,view.y])
        @zoom.scale(newScale)

        #translate workspace
        @workspace.transition().ease("linear").attr "transform", "translate(#{[view.x,view.y]}) scale(#{newScale})"
