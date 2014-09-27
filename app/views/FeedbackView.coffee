define ['jquery', 'feedback-bot'],
  ($, feedback) ->
    class FeedbackView extends Backbone.View
      el: $ 'body'

      initialize: ->
      	$.feedback({
      	  html2canvasURL: '/assets/libs/feedback-bot/src/html2canvas.min.js',
      	  githubpath: 'davidfurlong/cograph-feedback',
      	  serverURL: 'http://feedbackbot.herokuapp.com',
      	  placement: 'left'
      	})