var Express = require('express');
var app = Express();

var client = require('twilio')('AC8815762514fc3fd2ba16c0fc8e2c5d81', '3132ecbec50c5939b917389924c2e1bd');
app.use(Express.bodyParser());

app.post('/receive',
    function(req, res) {
        console.log(req.body.From);
        console.log(req.body.To);
        console.log(req.body.Body);
        var array = req.body.Body.split('#')[0];
        var message = array[0];
        var receiver = array[1];
        var sender = req.body.From;

        var User = Parse.Object.extend("User");
        var Contact = Parse.Object.extend("Contact");
        var queryForUser = new Parse.Query(User);
        var queryForContact = new Parse.Query(Contact);

        queryForUser.get(receiver, {
            success: function(user) {
                queryForContact.get(sender, {
                    success: function(contact) {
                        var Memo = Parse.Object.extend("Memo");
                        var memo = new Memo();
                        memo.set("text", "message");
                        memo.set("contact", contact);
                        memo.set("user", user);
                        memo.save(null, {
                            success:function (memo) {
                                console.log("Successfully saved a memo");
                            },
                            error:function (pointAward, error) {
                                console.log("Could not save " + error.message);
                            }
                        });
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
        body: 'Testinggg #' + request.params.userNumber
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
