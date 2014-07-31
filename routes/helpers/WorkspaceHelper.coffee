_ = require __dirname + '/../../node_modules/underscore/underscore'
utils = require __dirname + '/../utils'

class WorkspaceHelper
  constructor: (@graphDb) ->

  create: (newWorkspace, callback) ->
    workspaceLabel = "_workspace"
    params = {props: newWorkspace}
    cypherQuery = "CREATE (n:#{workspaceLabel} { props }) RETURN n;"
    @graphDb.query cypherQuery, params, (err, results) =>
      if (err) then throw err
      doc = utils.parseCypherResult(results[0], 'n')
      utils.setProperty @graphDb, doc.id, '_id', doc.id, (savedWorkspace) =>
        callback utils.parseNodeToClient savedWorkspace

module.exports = WorkspaceHelper
