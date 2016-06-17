var express = require('express');
var router = express.Router();
var exec = require('child_process').exec;
/* GET home page. */

var install_dir = '/var/www/gitwrapper/'
	
// var shell = {
// 	clone: function(name, sshURL, callback){
// 		return exec('git clone '+ sshURL + ' '+ install_dir + name, function(err, stdout, stderr){
// 			return callback(name, stdout);
// 	},
// 	setUpENV: function(){

// 	}
// };


var calls = {
	create: function(req, res, name, sshURL){
		return exec('bash create.sh '+name+' '+sshURL, function(err, stdout, stderr){
			return res.json({ title: 'Express' });
		});
	},
	update: function(name, sshURL){
		// git pull
		// run migrations
		// install req file
		// reload apache
	},
	delete: function(name){
		// delete dir
		// remove apache file
		// reload apache
	}

};


router.all('/', function(req, res, next) {
	var event = req.headers['x-github-event'];
	var call = (req.body.created && 'create') || (req.body.deleted && 'delete') || 'update';

	var name = req.body.ref.replace('refs/heads/', '');
	var sshURL = req.body.repository.ssh_url;

	return calls[call](req, res, name, sshURL);
});

module.exports = router;
