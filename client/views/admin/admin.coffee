TRS = @

Template.manageDepartments.helpers
  departments: TRS.Departments.find {}, {sort: ['department']}
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
    tags: [],
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
    TRS.Departments.update {_id: department_id}, {$set: {chairDMusers: e.val }}


Template.manageDepartmentDialog.helpers
  chairDMUsers: ->
    Meteor.users.find {}

Template.manageDepartmentDialog.rendered = ->
  $('')

Template.manageSemesters.helpers
  semesters: TRS.Semesters.find {}

Template.manageSemesters.events
  'click #clone_semester': ->
    $('#clone_semester_dialog').modal()
  'click #clone_semester_dialog button#clone': (e) ->
    oldSemesterName = $('#clone_semester_source').val()
    oldSemester = TRS.Semesters.findOne { semester: oldSemesterName }
    delete oldSemester._id
    delete oldSemester.dropdead
    oldSemester.semester = $('#clone_semester_name').val()
    TRS.Semesters.insert { semester: $('#clone_semester_name').val() }
    oldAllocations = TRS.FacultyAllocations.find { semester: oldSemesterName }
    oldAllocations.forEach (alloc) ->
      alloc.semester = newSemesterName
      delete alloc._id
      TRS.FacultyAllocations.insert alloc
    $('#clone_semester_dialog').modal('hide')

Template.manageSemesters.rendered = ->
  self = @
  data = @data
  $(@.findAll 'input.dropdead').datepicker
    format: 'mm/dd/yy'
  .on 'changeDate', (e) ->
    TRS.Semesters.update { _id: $(e.currentTarget).data 'id'}, {$set: {dropdead: $(e.currentTarget).val() } }
