define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  DataController =

    #should add a node to the database
    nodeAdd: (node) ->
      $.post "/server/create_node", node.attributes, (d) ->
        console.log "Added node ", d, " to the database"

    nodeDelete: (node) ->
      $.post "/server/delete_node", node.attributes, (d) ->
        if d then console.log "Deleted node from database"
