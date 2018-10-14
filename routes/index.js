'use strict';

const router = require('express').Router();

const {exec} = require('child_process');
var fs = require('fs');
/* GET home page. */

var install_dir = '/var/www/gitwrapper/'


// function lxc_create(name, callback) {
// 	exec('lxc-create', [
// 		'-n', 'name_'+(Math.random()*100).toString().slice(-4),
// 		'-t' 'download', '--',
// 		'--dist', 'ubuntu',
// 		'--release', 'xenial',
// 		'--arch', 'amd64']
// 	function(err, stdout, stderr){

// 	});
// }

var calls = {
	create: function(req, res, name, sshURL){
		console.log("create =========================");
		// create new container
		// install git in container
		// seed container with deploy key
		// clone repo into container
		// run <repo>/scripts/deploy/create
		// add entry to proxy





		return exec('bash /var/www/gitdeploy/create.sh '+name+' '+sshURL, function(err, stdout, stderr){
			console.log(err, stdout, stderr);
			return res.json({ title: stdout });
		});
	},
	update: function(req, res, name, sshURL){
		console.log("update =========================");
		return exec('bash /var/www/gitdeploy/update.sh '+name+' '+sshURL, function(err, stdout, stderr){
			console.log(err, stdout, stderr);
			return res.json({ title: stdout });
		});
	},
	delete: function(req, res, name, sshURL){
		console.log("delete =========================");
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
	console.log(req.body);

	var branch = req.body.ref.replace('refs/heads/', '');
	var sshURL = req.body.repository.ssh_url;

	console.log('branch', branch, 'sshURL', sshURL)
	// if(call === 'update' && !fs.existsSync('/var/wres.locals.messageww/gitwrapper/'+name)) call = 'create';


	// return calls[call](req, res, branch, sshURL);
});

module.exports = router;
