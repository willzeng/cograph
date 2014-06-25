utils = require __dirname + '/../routes/utils'
_ = require __dirname + '/../node_modules/underscore/underscore'

class NodeModel
  constructor: (@graphDb) ->

  # returns a populated instance of NodeModel from an id
  get: (id) ->
    true

  # Creates a Node whose labels are given by the tags argument
  # and with properties given by the props dictionary
  # Returns a dictionary that the client can handle
  create: (tags, props, docLabel, callback) ->
    tags = utils.listToLabels tags, "_tag_"
    tags += ":#{docLabel}"
    props = utils.dictionaryToCypherProperties props
    cypherQuery = "CREATE (n#{tags} {#{props}}) RETURN n;"
    @graphDb.query cypherQuery, {}, (err, results) =>
      if (err) then throw err
      node = utils.parseCypherResult(results[0], 'n')
      @setProperty node.id, '_id', node.id, (savedNode) =>
        callback utils.parseNodeToClient savedNode

  # Update a node with new tags and properties
  update: (id, tags, props, callback) ->
    props = utils.dictionaryToUpdateCypherProperties props

    utils.getTags @graphDb, id, (labels) =>
      parsedTags = utils.listToLabels tags, "_tag_"
      if parsedTags.length > 0 then parsedTags = "n #{parsedTags}, " else parsedTags = ""

      removedTags = _.difference labels, tags
      removedTags = utils.listToLabels removedTags, "_tag_"

      if removedTags.length > 0
        cypherQuery = "START n=node(#{id}) SET #{parsedTags}#{props} REMOVE n#{removedTags} RETURN n;"
      else
        cypherQuery = "START n=node(#{id}) SET #{parsedTags}#{props} RETURN n;"

      @graphDb.query cypherQuery, {}, (err, results) =>
        if err then throw err
        node = utils.parseCypherResult(results[0], 'n')
        callback utils.parseNodeToClient node

  # Sets node.property = value in @graphDb
  # Returns a dictionary that represents the server state of the node
  setProperty: (id, property, value, callback) ->
    cypherQuery = "START n=node(#{id}) SET n.#{property}=#{value} return n;"
    @graphDb.query cypherQuery, {}, (err, results) =>
      if err then throw err
      node = utils.parseCypherResult(results[0], 'n')
      callback node

  # Adds a label to a node identified by id
  setLabel: (id, label, callback) ->
    cypherQuery = "start n=node(#{id}) set n:#{label} return n"
    params = {}
    @graphDb.query cypherQuery, params, (err, results) ->
      if err then throw err
      setNode = utils.parseCypherResult(results[0], 'n')
      callback setNode

module.exports = NodeModel
