_ = require __dirname + '/../../node_modules/underscore/underscore'
utils = require __dirname + '/../utils'

class DocumentHelper
  constructor: (@graphDb) ->

  create: (newDocument, callback) ->
    docLabel = "_document"
    params = {props: newDocument}
    cypherQuery = "CREATE (n:#{docLabel} { props }) RETURN n;"
    @graphDb.query cypherQuery, params, (err, results) =>
      if (err) then throw err
      doc = utils.parseCypherResult(results[0], 'n')
      utils.setProperty @graphDb, doc.id, '_id', doc.id, (savedDoc) =>
        callback utils.parseNodeToClient savedDoc

  # Update a Document with new tags and properties
  update: (id, props, callback) ->
    params = {props: props, id: id}
    cypherQuery = "START n=node({ id }) SET n = { props } RETURN n;"

    @graphDb.query cypherQuery, params, (err, results) =>
      if err then throw err
      node = utils.parseCypherResult(results[0], 'n')
      callback utils.parseNodeToClient node


module.exports = DocumentHelper
