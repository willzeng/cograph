define ['jquery', 'underscore', 'backbone', 'text!templates/filters_template.html'],
  ($, _, Backbone, filtersTemplate) ->
    class FilterView extends Backbone.View

      el: $ '#filters-container'

      events:
        'click .filter-toggle': 'updateFilter'
        'click #filter-button': 'applyFilter'

      initialize: ->
        $(@el).append _.template(filtersTemplate, {tags:@model.get 'node_tags'})
        @workspaceModel = @attributes.workspaceModel

      update: ->
        $(@el).empty()

        $(@el).append _.template(filtersTemplate, {tags:@model.get 'node_tags'})

      updateFilter: (e) =>
        toggled = e.currentTarget
        if !toggled.checked
          @model.set 'node_tags', _.without @model.get('node_tags'), $(toggled).data('id')
        else
          @model.set 'node_tags', _.union @model.get('node_tags'), $(toggled).data('id')

      applyFilter: ->
        @workspaceModel.filter()
