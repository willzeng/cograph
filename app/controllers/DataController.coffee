define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  DataController =
    nodeAdd: (node, callback) ->
      $.post "/server/create_node", node.attributes, (d) ->
        console.log "Added node ", d, " to the database"
        callback d

    connectionAdd: (conn, callback) ->
      conn = conn.clone()
      newConn = conn.attributes
      newConn.source = conn.get('source').get('_id')
      newConn.target = conn.get('target').get('_id')
      $.post "/server/create_connection", newConn, (c) ->
        console.log "Added connection ", d, " to the database"
        callback c

    nodeEdit: (node) ->
      $.post "/server/update_node", node.attributes, (d) ->
        console.log "Updated node ", d

    nodeDelete: (node) ->
      $.post "/server/delete_node", node.attributes, (d) ->
        if d then console.log "Deleted node from database"
