_ = require __dirname + '/../../node_modules/underscore/underscore'
utils = require __dirname + '/../utils'

class WorkspaceHelper
  constructor: (@graphDb) ->

  create: (newWorkspace, callback) =>
    newWorkspace._docId = parseInt newWorkspace._docId
    params = {props: newWorkspace, docId:newWorkspace._docId}
    cypherQuery = "START m=node({ docId }) CREATE (n:_workspace { props })<-[r:HAS]-(m) RETURN n;"
    @graphDb.query cypherQuery, params, (err, results) =>
      if (err) then throw err
      doc = utils.parseCypherResult(results[0], 'n')
      utils.setProperty @graphDb, doc.id, '_id', doc.id, (savedWorkspace) =>
        callback utils.parseNodeToClient savedWorkspace

module.exports = WorkspaceHelper
