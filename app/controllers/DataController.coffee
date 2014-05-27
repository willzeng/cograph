define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->

  DataController =
    nodeAdd: (node, callback) ->
      $.post "/node/", node.serialize(), (d) ->
        console.log "Added node ", d, " to the database"
        callback d

    connectionAdd: (conn, callback) ->
      $.post "/connection/", conn.serialize(), (c) ->
        console.log "Added connection ", c, " to the database"
        callback c

    nodeEdit: (node) ->
      $.post "/node/#{node.get('_id')}", node.serialize(), (d) ->
        console.log "Updated node ", d

    connectionEdit: (conn) ->
      $.post "/connection/#{conn.get('_id')}", conn.serialize(), (d) ->
        console.log "Updated conn ", d

    objDelete: (type, obj) ->
      $.ajax
        url: "/#{type}/#{obj.get('_id')}"
        type: "DELETE"
        success: (d) ->
          if d then console.log "Deleted #{type} from database"
