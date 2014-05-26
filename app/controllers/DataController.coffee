define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  DataController =
    nodeAdd: (node, callback) ->
      $.post "/server/create_node", node.serialize(), (d) ->
        console.log "Added node ", d, " to the database"
        callback d

    connectionAdd: (conn, callback) ->
      $.post "/server/create_connection", conn.serialize(), (c) ->
        console.log "Added connection ", c, " to the database"
        callback c

    nodeEdit: (node) ->
      $.post "/server/update_node", node.serialize(), (d) ->
        console.log "Updated node ", d

    nodeDelete: (node) ->
      $.post "/server/delete_node", node.serialize(), (d) ->
        if d then console.log "Deleted node from database"
