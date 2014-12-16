// config/database.js
url = process.env.MONGOHQ_URL ||
	// 'mongodb://localhost:27017';
  'mongodb://wzeng:mongotester@kahana.mongohq.com:10078/app27380840';
  // looks like mongodb://<user>:<pass>@mongo.onmodulus.net:27017/Mikha4ot

module.exports = {
  'url' :  url
};