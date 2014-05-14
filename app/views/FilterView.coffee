define ['jquery', 'underscore', 'backbone', 'text!templates/filters_template.html'],
  ($, _, Backbone, filtersTemplate) ->
    class FilterView extends Backbone.View

      el: $ '#filters-container'

      initialize: ->
        @model.on 'change', @update, this

      update: ->
        $(@el).empty()

        $(@el).append _.template(filtersTemplate, {tags:@model.get 'node_tags'})
