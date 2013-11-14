@Semesters = new Meteor.Collection 'semesters'
@Departments = new Meteor.Collection 'departments'
@FacultyAllocations = new Meteor.Collection 'allocations'

if Meteor.isClient
  Template.mainMenu.helpers
    semesters: Semesters.find {}
    departments: Departments.find {}

  Template.mainMenu.events
    'click #clone_semester': ->
      $('#clone_semester_dialog').modal()
    'click button#clone': (e) ->
      Semesters.insert Semester.findOne { semester: $('#clone_semester_name').val() }
      $('#clone_semester_dialog').modal('hide')

  Template.manageDepartments.helpers
    departments: Departments.find {}, {sort: ['department']}
    users: Meteor.users.find {}

  Template.manageDepartments.events
    'click .edit-department': (e) ->
      $(Template.manageDepartmentDialog { department: @department, @chairDMusers }).modal()

  Template.departmentUsersSelect.usernames = ->
    if @chairDMusers?
      return @chairDMusers.join ','
    else
      return ''

  Template.departmentUsersSelect.rendered = ->
    data = @data
    department_id = @data._id
    $(@.find '.chair-dm-users').select2
      tags: ['fart'],
      tokenSeparators: [',', ' ', '\n'],
      multiple: true,
      initSelection: (e, cb) ->
        console.log data
        cb $(data.chairDMusers).map (e,o) ->
          {id: o, text: o}
      createSearchChoice: (term) ->
        return {id: term, text: term}
      query: (q) ->
        q.callback
          results: Meteor.users.find({ username: { $regex: '^'+q.term } }).map (doc, index) ->
            {id: doc.username, text: doc.username}
    .change (e) ->
      Departments.update {_id: department_id}, {$set: {chairDMusers: e.val }}
  

  Template.manageDepartmentDialog.helpers
    chairDMUsers: ->
      Meteor.users.find {}

  Template.manageDepartmentDialog.rendered = ->
    $('')

  Template.manageSemesters.helpers
    semesters: Semesters.find {}

  Template.manageSemesters.events
    'click #clone_semester': ->
      $('#clone_semester_dialog').modal()
    'click button#clone': (e) ->
      Semesters.insert { semester: $('#clone_semester_name').val() }
      $('#clone_semester_dialog').modal('hide')

  Template.manageSemesters.rendered = ->
    self = @
    data = @data
    $(@.findAll 'input.dropdead').datepicker
      format: 'mm/dd/yy'
    .on 'changeDate', (e) ->
      Semesters.update { _id: $(e.currentTarget).data 'id'}, {$set: {dropdead: $(e.currentTarget).val() } }

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

    FacultyAllocations.remove {}
    FacultyAllocations.insert
      name: 'Anglin, Mary K.'
      rank: 'Assoc.'
      buyout: 'n/a'
      pay_amount: null
      comment: ''
      courses:
        semester: 'Spring 2012'
        department: 'Anthropology'
        prefix: 'ANT'
        number: '330'
        credits: 3
        