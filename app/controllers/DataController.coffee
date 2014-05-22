define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  DataController = 

    init: (instances) ->
      console.log 'init DataController'

    #should add a node to the database
    nodeAdd: (node) ->
      console.log "adding: ", node
      $.post "/create_node", node

    # makes an ajax request to url with data and calls callback with response
    ajax: (url, data, callback) ->
      $.ajax
        url: url
        data: data
        success: callback
