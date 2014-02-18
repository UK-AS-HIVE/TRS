
Handlebars.registerHelper(
  "linkblueLogin",
  function (option) {
    return new Handlebars.SafeString(Template._linkblueLogin());
  }
);

Template._linkblueLogin.events({
  'click button[name="login"]': function(e, tpl) {
    logIn(e, tpl);
  },
  'click button[name="logout"]': function(e) {
    Meteor.logout();
  },
  'keydown input[name="password"]': function(e, tpl) {
    if (event.which == 13) {
      logIn(e,tpl);
    }
    },
  'keydown input[name="linkblue"]': function(e, tpl) {
    if (event.which == 13) {
      logIn(e,tpl);
    } 
  },
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


function logIn(e, tpl) {
      var username = $(tpl.find('input[name="linkblue"]')).val();
      var password = $(tpl.find('input[name="password"]')).val();
      Meteor.loginWithLdap(username, password, function() {
      console.log ('Callback from Meteor.loginWithLdap');
      console.log (Meteor.userId());});
    
  }


