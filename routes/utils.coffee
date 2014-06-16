_ = require __dirname + '/../node_modules/underscore'

utils =

  #takes a cypher query result array and the name of the returned cypher variable
  parseCypherResult: (obj, name) ->
    objData = obj[name]._data.data
    objData._id = @trim obj[name]._data.self
    objData

  dictionaryToCypherProperties: (dict) ->
    str = ""
    for key, value of dict
      str += "#{key}:'#{value}', "
    str.slice(0,-2)

  dictionaryToUpdateCypherProperties: (dict) ->
    str = ""
    for key, value of dict
      str += "n.#{key}='#{value}', "
    str.slice(0,-2)

  listToLabels: (list) ->
    str = ":"
    for item in list
      str += "#{item}:"
    str.slice(0,-1)

  #Trims a url i.e. 'http://localhost:7474/db/data/node/312' -> 312
  trim: (string)->
    string.match(/[0-9]*$/)[0]

  # Creates a Node whose labels are given by the tags argument
  # and with properties given by the props dictionary
  createNode: (graphDb, tags, props, callback) ->
    tags = @listToLabels tags
    props = @dictionaryToCypherProperties props

    cypherQuery = "CREATE (n#{tags} {#{props}}) RETURN n;"
    graphDb.query cypherQuery, {}, (err, results) =>
      node = utils.parseCypherResult(results[0], 'n')
      @nodeSet graphDb, node, '_id', node._id, (savedNode) ->
        callback savedNode

  updateNode: (graphDb, id, tags, props, callback) ->
    props = @dictionaryToUpdateCypherProperties props

    @getLabels graphDb, id, (labels) =>
      parsedTags = @listToLabels tags

      removedTags = _.difference labels, tags
      removedTags = @listToLabels removedTags

      if removedTags.length > 0
        cypherQuery = "START n=node(#{id}) SET n #{parsedTags}, #{props} REMOVE n#{removedTags} RETURN n;"
      else
        cypherQuery = "START n=node(#{id}) SET n #{parsedTags}, #{props} RETURN n;"

      graphDb.query cypherQuery, {}, (err, results) ->
        node = utils.parseCypherResult(results[0], 'n')
        callback node

  # Sets node.property = value in graphDb
  nodeSet: (graphDb, node, property, value, callback) ->
    id = node._id
    cypherQuery = "START n=node(#{id}) SET n.#{property}=#{value} return n;"
    graphDb.query cypherQuery, {}, (err, results) ->
      node = utils.parseCypherResult(results[0], 'n')
      callback node

  # Returns all the Neo4j Labels for a node with id
  getLabels: (graphDb, id, callback) ->
    cypherQuery = "START n=node(#{id}) return labels(n);"
    graphDb.query cypherQuery, {}, (err, results) ->
      labels = results[0]['labels(n)']
      callback labels

  # Input: A node dictionary
  # Output: A node dictionary with node.tags = [ label0, label1,... ]
  # for Neo4j labels
  labeler: (graphDb, node, callback) ->
    @getLabels graphDb, node._id, (labels) ->
      node.tags = labels
      callback null, node

  # returns all of the connections between id and any of the nodes
  get_connections: (graphDb, id, nodes, callback) ->
    cypherQuery = "START n=node(#{id}), m=node(#{nodes}) MATCH p=(n)-[]-(m) RETURN relationships(p);"
    params = {}
    graphDb.query cypherQuery, params, (err, results) ->
      conns = ((val for key, val of result)[0][0]._data.data for result in results)
      callback conns

module.exports = utils
