_ = require __dirname + '/../../node_modules/underscore/underscore'
utils = require __dirname + '/../utils'

class DocumentHelper
  constructor: (@graphDb) ->

  create: (newDocument, callback) ->
    docLabel = "_document"
    props = utils.dictionaryToCypherProperties newDocument
    cypherQuery = "CREATE (n:#{docLabel} {#{props}}) RETURN n;"
    @graphDb.query cypherQuery, {}, (err, results) =>
      if (err) then throw err
      doc = utils.parseCypherResult(results[0], 'n')
      utils.setProperty @graphDb, doc.id, '_id', doc.id, (savedDoc) =>
        callback utils.parseNodeToClient savedDoc


module.exports = DocumentHelper
