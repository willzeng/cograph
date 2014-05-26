define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  DataController =
    nodeAdd: (node, callback) ->
      $.post "/node/", node.attributes, (d) ->
        console.log "Added node ", d, " to the database"
        callback d

    connectionAdd: (conn, callback) ->
      newConn = conn.clone().attributes
      newConn.source = conn.get('source').get('_id')
      newConn.target = conn.get('target').get('_id')
      $.post "/connection/", newConn, (c) ->
        console.log "Added connection ", c, " to the database"
        callback c

    nodeEdit: (node) ->
      $.post "/node/#{node.get('_id')}", node.attributes, (d) ->
        console.log "Updated node ", d

    nodeDelete: (node) ->
      $.ajax
        url: "/node/#{node.get('_id')}"
        type: "DELETE"
        success: (d) ->
          if d then console.log "Deleted node from database"
