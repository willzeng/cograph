_ = require __dirname + '/../../node_modules/underscore/underscore'
utils = require __dirname + '/../utils'

class NodeHelper
  constructor: (@graphDb) ->

  # Creates a Node whose labels are given by the tags argument
  # and with properties given by the props dictionary
  # Returns a dictionary that the client can handle
  create: (tags, props, docLabel, callback) ->
    tags = utils.listToLabels tags, "_tag_"
    tags += ":#{docLabel}"
    params = {props: props}
    cypherQuery = "CREATE (n#{tags} { props }) RETURN n;"
    @graphDb.query cypherQuery, params, (err, results) =>
      console.log "graphDb CREATED node", utils.parseCypherResult(results[0], 'n')
      if (err) then throw err
      node = utils.parseCypherResult(results[0], 'n')
      utils.setProperty @graphDb, node.id, '_id', node.id, (savedNode) =>
        callback utils.parseNodeToClient savedNode

  # Update a node with new tags and properties
  update: (id, tags, props, callback) ->

    utils.getTags @graphDb, id, (labels) =>
      parsedTags = utils.listToLabels tags, "_tag_"
      if parsedTags.length > 0 then parsedTags = "SET n #{parsedTags} " else parsedTags = ""

      removedTags = _.difference labels, tags
      removedTags = utils.listToLabels removedTags, "_tag_"

      params = { props: props, id: id }

      if removedTags.length > 0
        cypherQuery = "START n=node({ id }) #{parsedTags} SET n = { props } REMOVE n#{removedTags} RETURN n;"
      else
        cypherQuery = "START n=node({ id }) #{parsedTags} SET n = { props } RETURN n;"

      @graphDb.query cypherQuery, params, (err, results) =>
        if err then throw err
        node = utils.parseCypherResult(results[0], 'n')
        node = utils.parseNodeToClient node
        node.tags = tags
        callback node

  # Adds a label to a node identified by id
  setLabel: (id, label, callback) ->
    cypherQuery = "start n=node({ id }) set n:#{label} return n"
    params = { id: id }
    @graphDb.query cypherQuery, params, (err, results) ->
      if err then throw err
      setNode = utils.parseCypherResult(results[0], 'n')
      callback setNode

  getNeighbors: (id, callback) ->
    params = {id: id}
    cypherQuery = "START n=node({id}) MATCH (n)<-->(m) RETURN m, labels(m);"
    @graphDb.query cypherQuery, params, (err, results) ->
      parsedNodes = []
      for node in results
        nodeData = node.m._data.data
        nodeData.tags = node['labels(m)']
        parsedNodes.push utils.parseNodeToClient nodeData
      callback parsedNodes

module.exports = NodeHelper
