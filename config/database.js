// config/database.js
url = process.env.MONGOHQ_URL ||
	// 'mongodb://localhost:27017';
  'mongodb://wzeng:mongotester@kahana.mongohq.com:10078/app27380840'; //This is just a public sandbox database of users for local testing

module.exports = {
  'url' :  url
};
