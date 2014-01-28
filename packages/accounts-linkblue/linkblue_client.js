
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
      console.log (Meteor.userId());
    });
  },
  'click button[name="logout"]': function(e) {
    Meteor.logout();
  }
});

Meteor.loginWithLdap = function (username, password, callback) {
  Accounts.callLoginMethod({
    methodName: 'loginWithLdap',
    methodArguments: [{username: username, password: password}],
    validateResult: function (result) {
      console.log ('validating results of login attempt...');
      console.log (result);
    },
    userCallback: callback
  });
};
