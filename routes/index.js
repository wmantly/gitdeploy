var express = require('express');
var router = express.Router();
var exec = require('child_process').exec;
/* GET home page. */
router.all('/', function(req, res, next) {
    console.log("some one is here");
    if(req.headers['x-github-event'] === 'push'){
	console.log("got a push!");
        if(req.body.ref === "refs/heads/master"){
            console.log('time to update master!');
            exec('/var/www/gitwrapperdeploy.sh', console.log, console.log);
        }
    }
  res.render('index', { title: 'Express' });
});

module.exports = router;
