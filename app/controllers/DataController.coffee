define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  DataController =
    nodeAdd: (node) ->
      $.post "/server/create_node", node.attributes, (d) ->
        console.log "Added node ", d, " to the database"

    nodeEdit: (node) ->
      $.post "/server/update_node", node.attributes, (d) ->
        console.log "Updated node ", d

    nodeDelete: (node) ->
      $.post "/server/delete_node", node.attributes, (d) ->
        if d then console.log "Deleted node from database"
