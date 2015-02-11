_ = require __dirname + '/../../node_modules/underscore/underscore'
utils = require __dirname + '/../utils'
async = require 'async'

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

      # find the unique mentioned twitter handles
      mentionedHandles = []
      tweet2Mentions = {}
      for tweet in tweets
        for mention in tweet.mentions
          mentionedHandles.push {name:mention.name, sn:mention.screen_name}
      mentionedHandles = _.uniq mentionedHandles, (t) -> t.sn

      # Add the tweet nodes to the new document
      saveTweetPara = []
      for tweet in tweets
        saveTweetPara.push @makeTweetNode(savedDocument._id, tweet, callback)
        # saveTweetPara.push (callback) =>
        #   @makeTweetNode(savedDocument._id, tweet, callback)
      async.parallel saveTweetPara, (err, savedNodes) =>
        if not err
          # Add the twitter handle nodes to the new document
          @addTwitterHandles savedDocument._id, mentionedHandles, (err, savedHandles) ->
            # Add connections between tweets and the nodes they are connected to
            # for node in savedNodes
            #   console.log "NODE: ", node
            #   source = node.id
            #   mentions = JSON.parse(node.mentions)
            #   console.log "MENTIONS: ", mentions
            #   for mention in mentions
            #     console.log "SAVEDHANDLES", savedHandles
            #     console.log "NAME", "@"+mention
            #     target = _.findWhere(savedHandles, {name:"@"+mention})
            #     console.log "TARGET", target
            #     console.log "CREATE A CONNECTION FROM: ", source, " to ", target.id
            # cypherQuery = "start n=node(#{source}), m=node(#{target}) create n-[r:connection]->m return n;"
            # @graphDb.query cypherQuery, params, (err, results) ->

  # Merges the twitter cograph with new tweets
  updateTwitterCograph: (twitterCograph, tweets) ->
    newTweetIds = (t.id for t in tweets)
    @getByIds twitterCograph, (documents) =>
      doc = documents[0] #twitterCograph is one id, so there's only one document
      oldTweetIds = if doc.tweetIds_str? then JSON.parse(doc.tweetIds_str) else []
      newTweets = (t for t in tweets when not _.contains oldTweetIds, t.id)
      mentionedHandles = []
      for tweet in newTweets
        @makeTweetNode doc._id, tweet
        for mention in tweet.mentions
          mentionedHandles.push {name:mention.name, sn:mention.screen_name}
      # find the unique mentioned twitter handles
      mentionedHandles = _.uniq mentionedHandles, (t) -> t.sn
      # Add the twitter handle nodes to the new document
      @addTwitterHandles(doc._id, mentionedHandles)        
      # update the unique twitter string ids
      doc.tweetIds_str = JSON.stringify _.union(newTweetIds, oldTweetIds)
      @update doc._id, doc

  # Creates a new cograph node from a tweet object in the
  # specified document
  makeTweetNode: (docId, tweet, callback) ->
    (callback) =>
      tweetText = tweet.text
      name = tweetText.substring(0,25)
      if name.length >= 25
        name += "..."
      mention_str = JSON.stringify (m.screen_name for m in tweet.mentions)
      tweetNode =
        name: name
        description: tweetText
        _docId: docId
        mentions: mention_str
      docLabel = "_doc_#{docId || 0}"
      @serverNode.create ['tweet'], tweetNode, docLabel, (savedNode) ->
        if callback? then callback null, savedNode

  # Merges nodes that represent twitter handles into the cograph
  addTwitterHandles: (docId, handles, callback) ->
    docLabel = "_doc_#{docId || 0}"
    # Get all the names of the nodes in the document
    cypherQuery = "match (n:_doc_#{docId}) return n.name, n._id;"
    @graphDb.query cypherQuery, {}, (err, results) =>
      names = (node['n.name'] for node in results)
      # Only add handles that do not already have a node in the cograph
      handles = _.filter handles, (h) ->
        not _.contains(names, "@"+h.sn)

      # Add the tweet nodes to the new document
      saveHandlePara = []
      handleFactory = (handle, callback) =>
        (callback) =>
          handleNode =
            name: "@"+handle.sn
            description: "http://twitter.com/"+handle.sn
            _docId: docId
            url: ""
          @serverNode.create [], handleNode, docLabel, (savedNode) ->
            if savedNode
              callback null, savedNode
            else
              callback true, null

      for handle in handles
        saveHandlePara.push handleFactory(handle)

      # Add the handle nodes to the document
      async.parallel saveHandlePara, (err, savedHandles) =>
        if not err
          callback err, savedHandles

module.exports = DocumentHelper
