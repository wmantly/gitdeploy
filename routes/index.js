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
	create: function(name, sshURL){
		exec('git clone '+ sshURL + ' /var/www/gitwrapper/'+ name, function(err, stdout, stderr){
			// set up virtual env
			// install req file
			// sync db
			// run migrations
			// write apache file
			// reload apache
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
	exec('pwd', console.log);
	console.log('call', call, 'event:', event, 'name:', name, 'sshURL:', sshURL)
	// console.log("\n=================\n\n", req.body);
/*    if(req.headers['x-github-event'] === 'push'){
        if(req.body.ref === "refs/heads/master"){
            console.log('time to update master!');
            exec('/var/www/gitwrapperdeploy.sh', console.log, console.log);
        }
    }*/
  res.json({ title: 'Express' });
});

module.exports = router;
