express = require 'express'
router = express.Router()

router.get('/test_route', (req, res) ->
  res.render('test.jade')
  )

module.exports = router
