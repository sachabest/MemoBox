var Express = require('express');
var app = Express();

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
                            //code to add image to parse
                            Parse.Cloud.httpRequest({
                                url: req.body.MediaUrl0,
                                success: function(response) {
                                    // The file contents are in response.buffer.
                                    contact.set('photo', response.buffer);
                                    contact.save();
                                }, 
                                error:function(error){
                                    console.log("unable to update photo");
                                }
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

// Create the Cloud Function
Parse.Cloud.define("requestMemo", function(request, response) {
    console.log("requesting memo!!!!!!");
    client.sendSms({
        to: request.params.receiverNumber,
        from: '+14157636299',
        body: 'Hi there!' + request.params.username + 'would love a brief summary of your last conversation. Please write a' +
            ' few sentences ending with #' + request.params.userNumber + '.'
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
});