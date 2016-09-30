var express = require('express');
var router = express.Router();
var exec = require('child_process').exec;
var fs = require('fs');
/* GET home page. */

var install_dir = '/var/www/gitwrapper/'



var calls = {
	create: function(req, res, name, sshURL){
		return exec('bash /var/www/gitdeploy/create.sh '+name+' '+sshURL, function(err, stdout, stderr){
			console.log(err, stdout, stderr);
			return res.json({ title: stdout });
		});
	},
	update: function(req, res, name, sshURL){
		return exec('bash /var/www/gitdeploy/update.sh '+name+' '+sshURL, function(err, stdout, stderr){
			console.log(err, stdout, stderr);
			return res.json({ title: stdout });
		});
	},
	delete: function(req, res, name, sshURL){
		return exec('bash /var/www/gitdeploy/delete.sh '+name+' '+sshURL, function(err, stdout, stderr){
			console.log(err, stdout, stderr);
			return res.json({ title: stdout });
		});
	}

};


router.all('/', function(req, res, next) {
	var event = req.headers['x-github-event'];
	var call = (req.body.created && 'create') || 
		(req.body.deleted && 'delete') || 
		'update';

	var name = req.body.ref.replace('refs/heads/', '');
	var sshURL = req.body.repository.ssh_url;
	if(call === 'update' && !fs.existsSync('/var/www/gitwrapper/'+name)) call = 'create';

	return calls[call](req, res, name, sshURL);
});

module.exports = router;
