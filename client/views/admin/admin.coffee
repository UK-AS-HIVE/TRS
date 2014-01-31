TRS = @

Template.manageDepartments.helpers
  departments: TRS.Departments.find {}, {sort: ['department']}
  users: Meteor.users.find {}

Template.manageDepartments.events
  'click .edit-department': (e) ->
    $(Template.manageDepartmentDialog { department: @department, @chairDMusers }).modal()
  'click #add-department': (e) ->
    bootbox.prompt 'Name of department to add:', (result) ->
      if result? then TRS.Departments.insert { department: result }
  'click .icon-trash': (e) ->
    self = @
    prompt = 'Delete department <em>' + @department + '</em>?'
    bootbox.confirm prompt, (result) ->
      TRS.Departments.remove {_id: self._id} if result is true

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

Template.manageAdmins.usernames = ->
  admins = TRS.Admins.findOne {}
  console.log admins
  if admins?
    console.log 'Admins are: ' + admins.admins.join(',')
    return admins.admins.join ','
  else
    return ''

Template.manageAdmins.rendered = ->
  console.log 'managedAdmins.rendered'
  console.log @
  $(@.find '.admin-users').select2
    tags: []
    tokenSeparators: [',', ' ', '\n']
    multiple: true
    initSelection: (e, cb) ->
      admins = TRS.Admins.findOne {}
      if admins?
        return cb $(admins.admins).map (e,o) ->
          {id: o, text: o}
    createSearchChoice: (term) ->
      return {id: term, text: term}
    query: (q) ->
      q.callback
        results: Meteor.users.find({ username: { $regex: '^'+q.term } }).map (doc, index) ->
          {id: doc.username, text: doc.username}
  .change (e) ->
    console.log 'ADMINS'
    console.log e
    #TRS.Admins.upsert {}, {admins: e.val }
    Meteor.call 'upsertAdmins', e.val

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
    newSemesterName = $('#clone_semester_name').val()
    oldSemester.semester = newSemesterName
    TRS.Semesters.insert { semester: newSemesterName }
    oldAllocations = TRS.FacultyAllocations.find { semester: oldSemesterName }
    oldAllocations.forEach (alloc) ->
      alloc.semester = newSemesterName
      delete alloc._id
      TRS.FacultyAllocations.insert alloc
    $('#clone_semester_dialog').modal('hide')
  'click .icon-trash': ->
    self = @
    prompt = 'Delete semester <em>' + @semester + '</em>?'
    bootbox.confirm prompt, (result) ->
      TRS.Semesters.remove {_id: self._id} if result is true



Template.manageSemesters.rendered = ->
  self = @
  data = @data
  $(@.findAll 'input.dropdead').datepicker
    format: 'mm/dd/yy'
  .on 'changeDate', (e) ->
    TRS.Semesters.update { _id: $(e.currentTarget).data 'id'}, {$set: {dropdead: $(e.currentTarget).val() } }
