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

  listToLabels: (list) ->
    str = ":"
    for item in list
      str += "#{item}:"
    str.slice(0,-1)

  #Trims a url i.e. 'http://localhost:7474/db/data/node/312' -> 312
  trim: (string)->
    string.match(/[0-9]*$/)[0]

  createNode: (graphDb, tags, props, callback) ->
    tags = @listToLabels tags
    props = @dictionaryToCypherProperties props

    cypherQuery = "CREATE (n#{tags} {#{props}}) RETURN n;"
    graphDb.query cypherQuery, {}, (err, results) ->
      node = utils.parseCypherResult(results[0], 'n')
      callback node

  nodeSet: (graphDb, node, property, value, callback) ->
    id = node._id
    cypherQuery = "START n=node(#{id}) SET n.#{property}=#{value} return n;"
    graphDb.query cypherQuery, {}, (err, results) ->
      node = utils.parseCypherResult(results[0], 'n')
      callback node

  getLabels: (graphDb, id, callback) ->
    cypherQuery = "START n=node(#{id}) return labels(n);"
    graphDb.query cypherQuery, {}, (err, results) ->
      labels = results[0]['labels(n)']
      callback labels

module.exports = utils
