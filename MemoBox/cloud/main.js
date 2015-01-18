var Express = require('express');
var app = Express();
var Image = require("parse-image");
var client = require('twilio')('AC8815762514fc3fd2ba16c0fc8e2c5d81', '3132ecbec50c5939b917389924c2e1bd');
app.use(Express.bodyParser());




app.post('/receive',
    function(req, res) {
        console.log("test " + req.body.MediaUrl0);
        console.log("test " + req.body.Body);

        var array = req.body.Body.split('#');
        var message = array[0];
        var user = array[1];
        var contact = req.body.From.substring(2);
        var User = Parse.Object.extend("User");
        var queryForUser = new Parse.Query(User);
        queryForUser.equalTo("username", user);

        queryForUser.first({
            success: function(user) {
                var Contact = Parse.Object.extend("Contact");
                var queryForContact = new Parse.Query(Contact);
                queryForContact.equalTo("phone", contact);
                queryForContact.equalTo("user", user);
                queryForContact.first({
                    success: function(contact) {
                        if(req.body.MediaUrl0 === undefined) {
                            var Memo = Parse.Object.extend("Memo");
                            var memo = new Memo();
                            memo.set("text", message);
                            memo.set("contact", contact);
                            memo.set("user", user);
                            memo.save(null, {
                                success:function (memo) {
                                    console.log("Successfully saved a memo");
                                    res.send("success");
                                },
                                error:function (pointAward, error) {
                                    console.log("Could not save " + error.message);
                                }
                            });
                        } else {
                            Parse.Cloud.httpRequest({url: req.body.MediaUrl0}).then(
                                    function(response) {
                                        console.log("received image");
                                        // The file contents are in response.buffer.
                                        contact.set('photo', response.buffer);
                                        console.log("saved");
                                    },
                                    function(error){
                                        console.log("made it to error");
                                        console.log(error.headers.Location);
                                        Parse.Cloud.httpRequest({url: error.headers.Location}).then(
                                            function(response) {
                                                var image = new Image();
                                                 image.setData(response.buffer, {
                                                	success:function(img) {
                                                		console.log("log image.data().toString():");
                                                		console.log(img.data().toString("base64"));
                                                		img.data({
                                                			success:function(buffer) {
																var file = new Parse.File("myfile.jpg", {base64: buffer.toString("base64")});
		                                                		file.save().then(function() {
		                                                			contact.set('photo', file);
		                                                			contact.save(null, {
			                                                   			success:function() {
			                                                        		console.log("save successfully");
			                                                    		},
			                                                    		error:function() {
			                                                        		console.log("save failed");
			                                                    		}
		                                                			});		},
		                                                			function(error) {
		                                                				console.log(error);
																});
                                                			}
                                                		});
                                                	},
                                                	error:function() {
                                                		console.log("invalid image data");
                                                	}
                                                });
                                            },
                                            function(error) {
                                                console.log("wrong error");
                                            });
                                    });
                        }
                    },
                    error: function(object, error) {
                        console.log("error querying for contact");
                    }
                });
            },
            error: function(object, error) {
                console.log("error querying for user");
            }
        });
    }
);

app.listen();

var requestPictureHelper = function(request) {
    console.log("requesting picture helper!");
    client.sendSms({
        to: request.params.receiverNumber,
        from: '+14157636299',
        body: 'Hi there!' + request.params.username + 'would love a picture of you to remember you by. Please add #' + request.params.userNumber + ' as a caption to the picture.'
    },
    function(err, responseData) {
        if (err) {
            console.log(err);
        } else {
            console.log(responseData.from);
            console.log(responseData.body);
        }
    }
    );
};

Parse.Cloud.define("requestPicture", function(request, response) {
    console.log("requesting picture!");
    requestPictureHelper(request);
});

// Create the Cloud Function
Parse.Cloud.define("requestMemo", function(request, response) {
    console.log("requesting memo!!!!!!");
    client.sendSms({
        to: request.params.receiverNumber,
        from: '+14157636299',
        body: 'Hi there! ' + request.params.username + 'would love a brief summary of your last conversation. Please write a'
         + ' few sentences ending with #' + request.params.userNumber + '.'
    },  function(err, responseData) {
            if (err) {
                console.log(err);
            } else {
                console.log(responseData.from);
                console.log(responseData.body);
            }
        }
    );

    //request picture if still not sent
    var User = Parse.Object.extend("User");
    var queryForUser = new Parse.Query(User);
    queryForUser.equalTo("username", request.params.userNumber);

    var Contact = Parse.Object.extend("Contact");
    var queryForContact = new Parse.Query(Contact);
    queryForContact.equalTo("phone", request.params.receiverNumber);

    queryForUser.first({
        success: function(user) {
            queryForContact.first({
                success: function(contact) {
                    console.log(contact);
                    if (contact.photo === undefined) {
                        requestPictureHelper(request);
                    }
                },
                error: function(object, error) {
                    console.log("error querying for contact");
                }
            });
        },
        error: function(object, error) {
            console.log("error querying for user");
        }
    });
});




