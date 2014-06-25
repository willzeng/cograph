_ = require __dirname + '/../node_modules/underscore'

utils =

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

  # returns all of the connections between the node identified by id
  # and any node in nodes
  get_connections: (graphDb, id, nodes, callback) ->
    cypherQuery = "START n=node(#{id}), m=node(#{nodes}) MATCH p=(n)-[]-(m) RETURN relationships(p);"
    params = {}
    graphDb.query cypherQuery, params, (err, results) ->
      conns = ((val for key, val of result)[0][0]._data.data for result in results)
      callback conns

  # takes a cypher query result array and the name of the returned cypher variable
  # goes into `_data.data` and returns an object that corresponds to attributes of a node
  parseCypherResult: (obj, name) ->
    objData = obj[name]._data.data
    objData.id = objData._id = @trim obj[name]._data.self
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
