url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'
_ = require __dirname + '/../node_modules/underscore/underscore'

# returns a list of objects for nodes in a given document
# each object has the _id and name of a node
exports.getNodeNames = (req, resp) ->
  docId = req.params.docId || 0
  cypherQuery = "match (n:_doc_#{docId}) return n.name, n._id;"
  graphDb.query cypherQuery, {}, (err, results) ->
    resp.send ({name: node['n.name'], _id: node['n._id']} for node in results)

# returns a list of tags in a given document
exports.getTagNames = (req, resp) ->
  docId = req.params.docId
  cypherQuery = "match (n:_doc_#{docId}) return labels(n)"
  graphDb.query cypherQuery, {}, (err, results) ->
    labels = _.uniq _.flatten _.map results, (result) -> result['labels(n)']
    labelDict = utils.parseLabels labels
    resp.send labelDict.tags

exports.getNodeByName = (req, resp) ->
  docId = req.params.docId
  name = req.query.name
  cypherQuery = "match (n:_doc_#{docId}) where n.name='#{name}' return n, labels(n) limit 1;"
  graphDb.query cypherQuery, {}, (err, results) ->
    if err then throw err
    nodeData = results[0].n._data.data
    nodeData.tags = utils.parseLabels(results[0]['labels(n)']).tags
    resp.send nodeData

exports.getNodesByTag = (req, resp) ->
  docId = req.params.docId
  tag = req.query.tag
  cypherQuery = "match (n:_tag_#{tag}:_doc_#{docId}) return n, labels(n);"
  graphDb.query cypherQuery, {}, (err, results) ->
    if err then throw err
    parsedNodes = []
    for node in results
      nodeData = node.n._data.data
      nodeData.tags = node['labels(n)']
      parsedNodes.push utils.parseNodeToClient nodeData
    resp.send parsedNodes
