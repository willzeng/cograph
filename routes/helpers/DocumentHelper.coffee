_ = require __dirname + '/../../node_modules/underscore/underscore'
utils = require __dirname + '/../utils'

NodeHelper = require './NodeHelper'

class DocumentHelper
  constructor: (@graphDb) ->
    @serverNode = new NodeHelper(@graphDb)

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
    params = {props: props, id: parseInt(id)}
    cypherQuery = "START n=node({ id }) SET n = { props } RETURN n;"
    @graphDb.query cypherQuery, params, (err, results) =>
      if err then throw err
      node = utils.parseCypherResult(results[0], 'n')
      callback utils.parseNodeToClient node

  # Gets all the public documents
  getAll: (callback) ->
    docLabel = '_document'
    cypherQuery = "MATCH (n:#{docLabel}) WHERE n.publicView=2 return n;"
    params = {}
    @graphDb.query cypherQuery, params, (err, results) ->
      if err then throw err
      nodes = (utils.parseCypherResult(node, 'n') for node in results)
      callback nodes

  # Gets documents with ids in list 'ids'
  getByIds: (ids, callback) ->
    if ids.length is 0
      callback []
    else
      params = {ids:ids}
      cypherQuery = "start n=node({ids}) return n;"
      @graphDb.query cypherQuery, params, (err, results) ->
        if err then throw err
        nodes = (utils.parseCypherResult(node, 'n') for node in results)
        callback nodes

  # Makes a document for imported Tweets
  createTwitterCograph: (username, profiledUser, tweetTexts, callback) ->
    twitterDoc =
      name: 'Tweets Cograph for @'+username
      createdBy: username
      description: 'This is a Cograph of your imported tweets!'
    @create twitterDoc, (savedDocument) =>
      # once the document is created the callback is sent
      callback savedDocument
      # Add the tweet nodes to the new document
      for tweet in tweetTexts
        name = tweet.substring(0,25)
        if name .length >= 25
          name += "..."
        tweetNode =
          name: name
          description: tweet
          _docId: savedDocument._id
        docLabel = "_doc_#{savedDocument._id || 0}"
        @serverNode.create ['tweet'], tweetNode, docLabel, (savedNode) ->
          return null

module.exports = DocumentHelper
