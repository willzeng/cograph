define ['jquery', 'feedback-bot', 'backbone'],
  ($, feedback, Backbone) ->
    class FeedbackView extends Backbone.View
      el: $ 'body'

      initialize: ->
      	$(document).ready(()=>
          $.feedback({
            html2canvasURL: '/assets/libs/feedback-bot/src/html2canvas.min.js',
            githubpath: 'davidfurlong/cograph-feedback',
            serverURL: 'http://feedbackbot.herokuapp.com',
            placement: 'left'
          })
        )
        