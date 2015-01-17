var Express = require('express');
var app = Express();

var client = require('twilio')('AC8815762514fc3fd2ba16c0fc8e2c5d81', '3132ecbec50c5939b917389924c2e1bd');
app.use(Express.bodyParser());

app.post('/receive',
         function(req, res) {
  console.log("test");
  console.log("Received a new text: " + req.body);
  console.log(req.body.From);
  console.log(req.body.To);
  console.log(req.body.Body);

  res.send('Success');
});
  
app.listen();
