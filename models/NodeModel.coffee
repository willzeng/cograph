Backbone = require __dirname + '/../node_modules/backbone'
utils = require __dirname + '/../routes/utils'

class NodeModel extends Backbone.Model
  # returns a populated instance of NodeModel from an id
  get: (graphDb, id) ->
    

  # Creates a Node whose labels are given by the tags argument
  # and with properties given by the props dictionary
  create: (graphDb, tags, props, callback) ->
    tags = utils.listToLabels tags, "_tag_"
    props = utils.dictionaryToCypherProperties props

    cypherQuery = "CREATE (n#{tags} {#{props}}) RETURN n;"
    graphDb.query cypherQuery, {}, (err, results) =>
      node = utils.parseCypherResult(results[0], 'n')
      @setProperty graphDb, node._id, '_id', node._id, (savedNode) =>
        callback savedNode

  update: (graphDb, id, tags, props, callback) ->
    props = utils.dictionaryToUpdateCypherProperties props

    utils.getTags graphDb, id, (labels) =>
      parsedTags = @listToLabels tags, "_tag_"
      if parsedTags.length > 0 then parsedTags = "n #{parsedTags}, " else parsedTags = ""

      removedTags = _.difference labels, tags
      removedTags = @listToLabels removedTags, "_tag_"

      if removedTags.length > 0
        cypherQuery = "START n=node(#{id}) SET #{parsedTags}#{props} REMOVE n#{removedTags} RETURN n;"
      else
        cypherQuery = "START n=node(#{id}) SET #{parsedTags}#{props} RETURN n;"

      graphDb.query cypherQuery, {}, (err, results) =>
        node = @parseCypherResult(results[0], 'n')
        callback node

  # Sets node.property = value in graphDb
  setProperty: (graphDb, id, property, value, callback) ->
    id = node._id
    cypherQuery = "START n=node(#{id}) SET n.#{property}=#{value} return n;"
    graphDb.query cypherQuery, {}, (err, results) ->
      node = utils.parseCypherResult(results[0], 'n')
      callback node

module.exports = NodeModel
