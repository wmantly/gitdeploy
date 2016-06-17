var express = require('express');
var router = express.Router();
var exec = require('child_process').exec;
var fs = require('fs');
var fs = fs.existsSync(dir)
/* GET home page. */

var install_dir = '/var/www/gitwrapper/'



var calls = {
	create: function(req, res, name, sshURL){
		return exec('bash create.sh '+name+' '+sshURL, function(err, stdout, stderr){
			return res.json({ title: 'Express' });
		});
	},
	update: function(name, sshURL){
		return exec('bash update.sh '+name+' '+sshURL, function(err, stdout, stderr){
			return res.json({ title: 'Express' });
		});
	},
	delete: function(name){
		return exec('bash delete.sh '+name+' '+sshURL, function(err, stdout, stderr){
			return res.json({ title: 'Express' });
		});
	}

};


router.all('/', function(req, res, next) {
	var event = req.headers['x-github-event'];
	var call = (req.body.created && 'create') || (req.body.deleted && 'delete') || 'update';

	var name = req.body.ref.replace('refs/heads/', '');
	var sshURL = req.body.repository.ssh_url;
	if(call === 'update' && !fs.existsSync('/var/www/gitwrapper/'+name)) call = 'create';

	return calls[call](req, res, name, sshURL);
});

module.exports = router;
