
/*UI.registerHelper(
  "linkblueLogin",
  function (option) {
    return new Spacebars.SafeString(Template.linkblueLogin());
  }
);*/

Template.linkblueLogin.events({
  'click button[name="login"]': function(e, tpl) {
    var username = $(tpl.find('input[name="linkblue"]')).val();
    var password = $(tpl.find('input[name="password"]')).val();
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
