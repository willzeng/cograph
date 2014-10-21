
module.exports = function(betaRequestConnection) {
	var BetaRequest = require('../models/beta-requests.coffee')(betaRequestConnection)

	m = new BetaUser();
	m.save();
}