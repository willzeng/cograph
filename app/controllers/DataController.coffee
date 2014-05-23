define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  DataController = 

    init: (instances) ->
      console.log 'init DataController'

    #should add a node to the database
    nodeAdd: (node) ->
      $.post "/server/create_node", node.attributes, (d) ->
        console.log "Added node ", d, " to the database"

    # makes an ajax request to url with data and calls callback with response
    ajax: (url, data, callback) ->
      $.ajax
        url: url
        data: data
        success: callback
