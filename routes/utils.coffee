utils =

  #takes a cypher query result array and the name of the returned cypher variable
  parseCypherResult: (obj, name) ->
    objData = obj[name]._data.data
    objData._id = @trim obj[name]._data.self
    objData

  #Trims a url i.e. 'http://localhost:7474/db/data/node/312' -> 312
  trim: (string)->
    string.match(/[0-9]*$/)[0]

module.exports = utils
