TRS = @

if Meteor.isClient
  Template.mainMenu.helpers
    semesters: TRS.Semesters.find {}
    departments: TRS.Departments.find {}

  Template.mainMenu.events
    'click #clone_semester': ->
      $('#clone_semester_dialog').modal()
    'click button#clone': (e) ->
      TRS.Semesters.insert TRS.Semesters.findOne { semester: $('#clone_semester_name').val() }
      $('#clone_semester_dialog').modal('hide')

if Meteor.isServer
  Meteor.startup ->

    ###
    Semesters.remove {}
    Semesters.insert { semester: 'Spring 2014' }
    Semesters.insert { semester: 'Fall 2014' }
    ###

    ###
    Departments.remove {}
    Departments.insert { department: 'Anthropology', chairDMusers: ['nkzakh0'] }
    Departments.insert { department: 'Biology' }
    ###

    ###
    FacultyAllocations.remove {}
    FacultyAllocations.insert
      name: 'Anglin, Mary K.'
      semester: 'Spring 2012'
      department: 'Anthropology'
      rank: 'Assoc.'
      buyout: 'n/a'
      pay_amount: null
      comment: ''
      courses:
        prefix: 'ANT'
        number: '330'
        credits: 3
    ###