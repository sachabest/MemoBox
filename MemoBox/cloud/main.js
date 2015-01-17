var Express = require('express');
var app = Express();

var client = require('twilio')('AC8815762514fc3fd2ba16c0fc8e2c5d81', '3132ecbec50c5939b917389924c2e1bd');

app.get('/receive',
         function(req, res) {
  console.log("test");
  console.log("Received a new text: " + req.body.From);
  res.send('Success');
});
  


app.get('/test',
		function(req, res) {
			console.log("stuff");
			res.send('Success');
		}
	);

app.listen();
