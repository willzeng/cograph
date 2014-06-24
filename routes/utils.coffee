_ = require __dirname + '/../node_modules/underscore'

utils =

  ###Neo4j NODES###

  #CREATE

  # Creates a Neo4jNode whose labels are given by the tags argument
  # and with properties given by the props dictionary
  createNode: (graphDb, tags, props, callback) ->
    tags = @listToLabels tags, "_tag_"
    props = @dictionaryToCypherProperties props

    cypherQuery = "CREATE (n#{tags} {#{props}}) RETURN n;"
    graphDb.query cypherQuery, {}, (err, results) =>
      node = utils.parseCypherResult(results[0], 'n')
      @nodeSet graphDb, node._id, '_id', node._id, (savedNode) =>
        callback savedNode

  #READ

  # Returns all the Neo4j Labels for a node with id
  getLabels: (graphDb, id, callback) ->
    cypherQuery = "START n=node(#{id}) return labels(n);"
    graphDb.query cypherQuery, {}, (err, results) =>
      labels = results[0]['labels(n)']
      callback @parseLabels labels

  # Returns only the labels that are tags
  getTags: (graphDb, id, callback) ->
    @getLabels graphDb, id, (labelsDict) ->
      callback labelsDict.tags

  #UPDATE

  # Updates a the node identified by id
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

  # Sets node.property = value in graphDb
  nodeSet: (graphDb, id, property, value, callback) ->
    id = node._id
    cypherQuery = "START n=node(#{id}) SET n.#{property}=#{value} return n;"
    graphDb.query cypherQuery, {}, (err, results) ->
      node = utils.parseCypherResult(results[0], 'n')
      callback node

  # Adds a label to a node identified by id
  setLabel: (graphDb, id, label, callback) ->
    cypherQuery = "start n=node(#{id}) set n:#{label} return n"
    params = {}
    graphDb.query cypherQuery, params, (err, results) ->
      setNode = utils.parseCypherResult(results[0], 'n')
      callback setNode

  #DELETE

  ###Neo4j CONNECTIONS###

  #CREATE

  #READ

  # returns all of the connections between the node identified by id
  # and any node in nodes
  get_connections: (graphDb, id, nodes, callback) ->
    cypherQuery = "START n=node(#{id}), m=node(#{nodes}) MATCH p=(n)-[]-(m) RETURN relationships(p);"
    params = {}
    graphDb.query cypherQuery, params, (err, results) ->
      conns = ((val for key, val of result)[0][0]._data.data for result in results)
      callback conns

  #UPDATE

  #DELETE

  ###HELPER METHODS###

  # takes a cypher query result array and the name of the returned cypher variable
  # goes into `_data.data` and returns an object that corresponds to attributes of a node
  parseCypherResult: (obj, name) ->
    objData = obj[name]._data.data
    objData._id = @trim obj[name]._data.self
    objData

  dictionaryToCypherProperties: (dict) ->
    _.map(_.keys(dict), (key) -> "#{key}:'#{dict[key]}'").join(', ')

  dictionaryToUpdateCypherProperties: (dict) ->
    _.map(_.keys(dict), (key) -> "n.#{key}='#{dict[key]}'").join(', ')

  listToLabels: (list, prefix) ->
    _.map(list, (item) -> ":#{prefix}#{item}").join('')

  #Trims a url i.e. 'http://localhost:7474/db/data/node/312' -> 312
  trim: (string)->
    string.match(/[0-9]*$/)[0]

  parseNodeToClient: (serverNode) ->
    serverNode.tags = @parseLabels(serverNode.tags).tags if serverNode.tags
    serverNode

  parseLabels: (labels) ->
    labelDict = {tags:[]}
    for label in labels
      # js doesn't support lookbehinds in regexes
      docRegex = new RegExp /^\_doc\_(\d+)/
      workspaceRegex = new RegExp /^\_workspace\_(\d+)/
      tagsRegex = new RegExp /^\_tag\_(.+)/

      if tagsRegex.test label
        labelDict.tags.push tagsRegex.exec(label)[1]
        continue
      if docRegex.test label
        labelDict.doc = docRegex.exec(label)[1]
        continue
      if workspaceRegex.test label
        labelDict.workspace = workspaceRegex.exec(label)[1]
        continue
    labelDict

  paramExtract: (name, fn) ->
    if fn instanceof RegExp
      return (req, res, next, val) ->
        if captures = fn.exec String(val)
          req.params[name] = captures
          next()
        else
          next 'route'

module.exports = utils
