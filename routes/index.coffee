express = require 'express'
router = express.Router()

utils = require './utils'
nodes = require './nodes'
connections = require './connections'
documents = require './documents'

router.get '/', (request, response)->
  response.render('index.jade')


router.get '/hello', (request, response)->
  response.send('index.jade')

#defines a function to extract parameters using regex's
router.param utils.paramExtract
router.param 'id', /^\d+$/

# Documents
router.post     '/documents',       documents.create
router.get      '/documents/:id',    documents.read
router.get      '/documents',       documents.getAll
router.put      '/documents',       documents.update
router.delete   '/documents',       documents.destroy

# Nodes
router.post     '/nodes',              nodes.create
router.get      '/nodes/:id',           nodes.read
router.get      '/nodes',              nodes.getAll
router.get      '/nodes/neighbors/:id', nodes.getNeighbors
router.get      '/nodes/spokes/:id',    nodes.getSpokes
router.put      '/nodes',              nodes.update
router.delete   '/nodes',              nodes.destroy

# Connections
router.post     '/conncetions',      connections.create
router.get      '/conncetions/:id',   connections.read
router.get      '/conncetions',      connections.getAll
router.put      '/conncetions',      connections.update
router.delete   '/conncetions',      connections.destroy

module.exports = router
