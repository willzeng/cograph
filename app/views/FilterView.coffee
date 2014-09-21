define ['jquery', 'underscore', 'backbone', 'text!templates/filters_template.html'],
  ($, _, Backbone, filtersTemplate) ->
    class FilterView extends Backbone.View

      el: $ '#sidebar'

      events:
        'click #filter-modal-toggle': 'openFilterModal'

      initialize: ->
        @workspaceModel = @attributes.workspaceModel

      openFilterModal: ->
        initialTags = @model.get 'initial_tags'
        checkedTags = @model.get 'node_tags'
        tagTable = {}
        for tag in initialTags
          tagTable[tag] = _.contains checkedTags, tag

        @FilterModal = new Backbone.BootstrapModal(
          content: _.template(filtersTemplate, {tagTable:tagTable})
          title: "Filters"
          animate: true
          showFooter: false
        ).open()

        $('.filter-toggle', @FilterModal.$el).click (e) =>
          @updateFilter e

        $('.filter-toggle-all', @FilterModal.$el).click (e) =>
          if !e.currentTarget.checked 
            $.each($('.filter-toggle'), (i, el) =>
              @model.set 'node_tags', _.without @model.get('node_tags'), $(el).data('id') 
              $(el).prop('checked', false)
            )
          else
            $.each($('.filter-toggle'), (i, el) =>
              @model.set 'node_tags', _.union @model.get('node_tags'), $(el).data('id')
              $(el).prop('checked', true)
            )

        $('#filter-button', @FilterModal.$el).click (e) =>
          @applyFilter()
          @FilterModal.close()

      updateFilter: (e) =>
        el = e.currentTarget
        if !el.checked
          @model.set 'node_tags', _.without @model.get('node_tags'), $(el).data('id')
        else
          @model.set 'node_tags', _.union @model.get('node_tags'), $(el).data('id')
        
      applyFilter: ->
        @workspaceModel.filter()
