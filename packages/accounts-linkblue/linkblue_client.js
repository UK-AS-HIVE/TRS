
Handlebars.registerHelper(
  "linkblueLogin",
  function (option) {
    return new Handlebars.SafeString(Template._linkblueLogin());
  }
);

Template._linkblueLogin.events({
  'click button[name="login"]': function(e) {
    var username = $(e.currentTarget).parent().find('input[name="linkblue"]').val();
    var password = $(e.currentTarget).parent().find('input[name="password"]').val();
    Meteor.loginWithLdap(username, password, function() {
      console.log ('Callback from Meteor.loginWithLdap');
    });
  },
  'click button[name="logout"]': function(e) {
    Meteor.logout();
  }
});


Meteor.loginWithLdap = function (username, password, callback) {
  /*var srp = SRP.Client(password);
  var request = srp.startExchange();

  request.user = {'username': username};*/

  Accounts._setLoggingIn(true);
  /*Meteor.apply('beginLdapPasswordExchange', [request], function (error, result) {
    if (error || !result) {
      Accounts._setLoggingIn(false);
      error = error || new Error("No result from call to beginLdapPasswordExchange");
      callback && callback(error);
      return;
    }

    var response = srp.respondToChallenge(result);*/
    Accounts.callLoginMethod({
      methodName: 'loginWithLdap',
      methodArguments: [{username: username, password: password}],
      validateResult: function (result) {
        console.log ('validating results of login attempt...');
        console.log (result);
        /*if (!srp.verifyConfirmation({HAMK: result.HAMK}))
          throw new Error("Server is cheating!");*/
      },
      userCallback: callback
    });
  //});
};
