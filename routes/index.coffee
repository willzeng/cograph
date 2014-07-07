express = require 'express'
router = express.Router()

utils = require './utils'
nodes = require './nodes'
connections = require './connections'
documents = require './documents'
search = require './search'

router.get '/', (request, response)->
  response.render('index.jade')

router.get '/landing', (request, response)->
  response.render('landing.jade')

router.get '/errors/missingDocument', (request, response)->
  response.render('errors/missingDocument.jade')

#defines a function to extract parameters using regex's
router.param utils.paramExtract
integerRegex = /^\d+$/
router.param 'id', integerRegex
router.param 'docId', integerRegex

# Nodes
router.get      '/documents/:docId/nodes/:id/neighbors/',       nodes.getNeighbors
router.get      '/documents/:docId/nodes/:id/spokes/',          nodes.getSpokes
router.post     '/documents/:docId/nodes/:id/get_connections/', nodes.getConnections

# Search
router.get      '/documents/:docId/nodes/names',       search.getNodeNames
router.get      '/documents/:docId/getNodeByName',     search.getNodeByName
router.get      '/documents/:docId/getNodesByTag',     search.getNodesByTag
router.get      '/documents/:docId/tags',              search.getTagNames

module.exports = router
