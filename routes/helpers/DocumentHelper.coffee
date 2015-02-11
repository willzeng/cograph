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
      if callback? then callback utils.parseNodeToClient node

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
  createTwitterCograph: (username, profiledUser, tweets, callback) ->
    tweetIds_str = JSON.stringify (t.id for t in tweets)
    twitterDoc =
      name: 'Tweets Cograph for @'+username
      createdBy: username
      description: 'This is a Cograph of your imported tweets!'
      tweetIds_str: tweetIds_str
    @create twitterDoc, (savedDocument) =>
      # once the document is created the callback is sent
      callback savedDocument
      # Add the tweet nodes to the new document
      for tweet in tweets
        @makeTweetNode savedDocument._id, tweet

  # Merges the twitter cograph with new tweets
  updateTwitterCograph: (twitterCograph, tweets) ->
    newTweetIds = (t.id for t in tweets)
    @getByIds twitterCograph, (documents) =>
      doc = documents[0] #twitterCograph is one id, so there's only one document
      oldTweetIds = if doc.tweetIds_str? then JSON.parse(doc.tweetIds_str) else []
      newTweets = (t for t in tweets when not _.contains oldTweetIds, t.id)
      for tweet in newTweets
        @makeTweetNode doc._id, tweet
      # update the unique twitter string ids
      doc.tweetIds_str = JSON.stringify _.union(newTweetIds, oldTweetIds)
      @update doc._id, doc

  # Creates a new cograph node from a tweet objects in the
  # specified document
  makeTweetNode: (docId, tweet, callback) ->
    tweetText = tweet.text
    name = tweetText.substring(0,25)
    if name.length >= 25
      name += "..."
      tweetNode =
        name: name
        description: tweetText
        _docId: docId
      docLabel = "_doc_#{docId || 0}"
      @serverNode.create ['tweet'], tweetNode, docLabel, (savedNode) ->
        if callback? then callback savedNode

module.exports = DocumentHelper
