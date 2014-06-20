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

  listToLabels: (list, prefix) ->
    str = ":"
    for item in list
      str += "#{prefix}#{item}:"
    str.slice(0,-1)

  #Trims a url i.e. 'http://localhost:7474/db/data/node/312' -> 312
  trim: (string)->
    string.match(/[0-9]*$/)[0]

  # Creates a Node whose labels are given by the tags argument
  # and with properties given by the props dictionary
  createNode: (graphDb, tags, props, callback) ->
    tags = @listToLabels tags, "_tag_"
    props = @dictionaryToCypherProperties props

    cypherQuery = "CREATE (n#{tags} {#{props}}) RETURN n;"
    graphDb.query cypherQuery, {}, (err, results) =>
      node = utils.parseCypherResult(results[0], 'n')
      @nodeSet graphDb, node, '_id', node._id, (savedNode) =>
        callback savedNode

  updateNode: (graphDb, id, tags, props, callback) ->
    props = @dictionaryToUpdateCypherProperties props

    @getTags graphDb, id, (labels) =>
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

  parseNodeToClient: (serverNode) ->
    clientNode = serverNode
    if serverNode.tags
      parsedLabels = @parseLabels serverNode.tags
      clientNode.tags = parsedLabels.tags
    clientNode

  parseLabels: (labels) ->
    labelDict = {tags:[]}
    for label in labels
      docRegex = new RegExp /\_doc\_\d+/
      workspaceRegex = new RegExp /\_workspace\_\d+/
      tagsRegex = new RegExp /\_tag\_.+/

      if docRegex.test label then labelDict.doc = label.slice(5)
      if workspaceRegex.test label then labelDict.workspace = label.slice(11)
      if tagsRegex.test label then labelDict.tags.push label.slice(5)
    labelDict

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
    graphDb.query cypherQuery, {}, (err, results) =>
      labels = results[0]['labels(n)']
      callback @parseLabels labels

  getTags: (graphDb, id, callback) ->
    @getLabels graphDb, id, (labelsDict) ->
      callback labelsDict.tags

  paramExtract: (name, fn) ->
    if fn instanceof RegExp
      return (req, res, next, val) ->
        if captures = fn.exec String(val)
          req.params[name] = captures
          next()
        else
          next 'route'

  setLabel: (graphDb, id, label, cb) ->
    cypherQuery = "start n=node(#{id}) set n:#{label} return n"
    params = {}
    graphDb.query cypherQuery, params, (err, results) ->
      setNode = utils.parseCypherResult(results[0], 'n')
      cb setNode

  # returns all of the connections between id and any of the nodes
  get_connections: (graphDb, id, nodes, callback) ->
    cypherQuery = "START n=node(#{id}), m=node(#{nodes}) MATCH p=(n)-[]-(m) RETURN relationships(p);"
    params = {}
    graphDb.query cypherQuery, params, (err, results) ->
      conns = ((val for key, val of result)[0][0]._data.data for result in results)
      callback conns

module.exports = utils
