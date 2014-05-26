utils =
  parseCypherNode: (node) ->
    nodeData = node.n._data.data
    nodeData._id = @trim node.n._data.self
    nodeData

  #Trims a url i.e. 'http://localhost:7474/db/data/node/312' -> 312
  trim: (string)->
    string.match(/[0-9]*$/)[0]

module.exports = utils
