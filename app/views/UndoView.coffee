define ['jquery', 'backbone', 'cs!views/GraphView'],
	($, Backbone, GraphView) ->
	  class UndoView extends Backbone.View
	    el: $ '#last-action'

	    events:
	      'click #undo-last-action': 'undoLastAction'

	    undoLastAction: ->
        @model.redo()