assert = require 'assert'

describe 'Admin functionality', ->
  GivenUserIsAdmin = (done, server, client) ->
    server.eval ->
      Meteor.methods
        'grantMeAdmin': ->
          testAdmin = Meteor.users.findOne @userId
          Admins.upsert {}, {$set: {admins: [testAdmin.username]}}
          emit 'adminGranted'
      
      emit 'setupComplete'
    
    server.once 'setupComplete', ->
      client.eval ->
        Accounts.createUser {username: 'testAdmin', password: 'irrelevant'}
        Meteor.call 'grantMeAdmin'
    
  it 'admins should have a link to Manage page', (done, server, client) ->
    # Given user is an administrator
    GivenUserIsAdmin done,server,client
  
    # When he looks at the main menu
    server.once 'adminGranted', ->
      client.eval ->
        waitForDOM '#main-menu', ->
          emit 'manageText', $('a[href="/manage"]').text()

    # Then he should see a link to the admin page with text 'Manage'
    client.once 'manageText', (manageText) ->
      assert.equal 'Manage', manageText
      done()

  it 'admin users can grant other users admin access', (done, server, client) ->
    # Given user is an administrator
    GivenUserIsAdmin done,server,client
    
    # When he upserts to set the admins
    server.once 'adminGranted', ->
      client.eval ->
        Meteor.call 'upsertAdmins', [Meteor.user().username, 'anotherAdmin'], -> emit 'upserted'

    # Then the admins should include the new admin
    client.once 'upserted', ->
      server.eval ->
        emit 'admins', Admins.findOne().admins
        
    server.once 'admins', (admins) ->
      assert.equal admins.length, 2
      for v,i in ['testAdmin', 'anotherAdmin']
        assert.equal admins[i], v
      done()
