express = require 'express'
nodes = express.Router()

url = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'
neo4j = require __dirname + '/../node_modules/neo4j'
graphDb = new neo4j.GraphDatabase url
utils = require './utils'

#defines a function to extract parameters using regex's
documents.param (name, fn) ->
  if fn instanceof RegExp
    return (req, res, next, val) ->
      if captures = fn.exec String(val)
        req.params[name] = captures
        next()
      else
        next 'route'

documents.param 'id', /^\d+$/

# CREATE

# READ

# UPDATE

# DELETE


module.exports = documents
