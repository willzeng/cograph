utils =

  #takes a cypher query result array and the name of the returned cypher variable
  parseCypherResult: (obj, name) ->
    objData = obj[name]._data.data
    objData._id = @trim obj[name]._data.self
    objData

  #Trims a url i.e. 'http://localhost:7474/db/data/node/312' -> 312
  trim: (string)->
    string.match(/[0-9]*$/)[0]

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
      setNode._id = id
      cb(err, setNode)

  # returns all of the connections between id and any of the nodes
  get_connections: (graphDb, id, nodes, callback) ->
    cypherQuery = "START n=node(#{id}), m=node(#{nodes}) MATCH p=(n)-[]-(m) RETURN relationships(p);"
    params = {}
    graphDb.query cypherQuery, params, (err, results) ->
      conns = ((val for key, val of result)[0][0]._data.data for result in results)
      callback conns

module.exports = utils
