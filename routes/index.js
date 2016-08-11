var express = require('express');
var router = express.Router();
var exec = require('child_process').exec;
/* GET home page. */
router.all('/', function(req, res, next) {
    console.log("some one is here");
    if(req.headers['x-github-event'] === 'push'){
	console.log("got a push!");
        if(req.body.ref === "refs/heads/prod"){
            console.log('time to update prod!');
            exec('/var/www/gitwrapperdeploy.sh', console.log, console.log);
        }
    }
  res.render('index', { title: 'Express' });
});

router.get('/dbdump', function(req, res, nex){
	res.sendFile('/var/backups/db/djangodump.json');
});

module.exports = router;
