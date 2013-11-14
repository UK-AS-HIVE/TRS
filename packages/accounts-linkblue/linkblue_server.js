Meteor.methods({
  loginWithLdap: function (request) {
    console.log ('Received request for LDAP password authentication:');
    console.log (request);

    // TODO: authenticate against LDAP

    // Go ahead and create a whole new fake user
    var userId;
    var user = Meteor.users.findOne({username: request.username});

    if (user) {
      userId = user._id;
    } else {
      userId = Meteor.users.insert({username: request.username});
    }

    var stampedToken = Accounts._generateStampedLoginToken();
    Meteor.users.update(userId,
      {$push: {'services.resume.loginTokens': stampedToken}}
    );

    return {
      id: userId,
      token: stampedToken.token
    };
  }
});

Accounts.registerLoginHandler(function (options) {
  console.log ("LDAP LOGIN HANDLER YO");
});

