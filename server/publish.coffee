TRS = @

# Utility functions
UserIsAdmin = (userId) ->
  return true
  user = Meteor.users.findOne {_id: userId}
  user? and TRS.Admins.findOne { admins: user.username }

UserCanAccessDepartment = (userId, department) ->
  user = Meteor.users.findOne {_id: userId}
  if user?
    if TRS.Departments.findOne { chairDMusers: user.username, department: department }
      return true
    if TRS.Admins.findOne { admins: user.username }
      return true
  return false

Meteor.publish 'semesters', ->
  TRS.Semesters.find()

TRS.Semesters.allow
  insert: UserIsAdmin
  update: UserIsAdmin
  remove: UserIsAdmin

Meteor.publish 'departments', ->
  if @userId
    user = Meteor.users.findOne {_id: @userId}
    if TRS.Admins.findOne { admins: user.username }
      return TRS.Departments.find {}, { sort: { department: 1 } }
    return TRS.Departments.find { chairDMusers: user.username }, { sort: { department: 1 } }

TRS.Departments.allow
  insert: UserIsAdmin
  update: UserIsAdmin
  remove: UserIsAdmin

Meteor.publish 'allocations', (department, semester) ->
  if UserCanAccessDepartment @userId, department
    return TRS.FacultyAllocations.find
      department: department
      semester: semester

TRS.FacultyAllocations.allow
  insert: (userId, doc) ->
    console.log 'INSERTING FACULTY ALLOCATION'
    return true
  update: (userId, doc, fieldNames, modifier) ->
    console.log 'CHANGING RECORD'
    console.log arguments
    ###TRS.DropDeadChanges.insert
      semester: doc.semester
      department: doc.department
      timestamp: new Date
      change:
        if modifier.hasOwnProperty '$set'
          'changed: ' + JSON.stringify modifier['$set']
        else if modifier.hasOwnProperty '$push'
          'added: ' + JSON.stringify modifier['$push']
    ###
    return true
  remove: (userId, doc) -> true

Meteor.publish 'semesterDepartmentDetail', (department, semester) ->
  if UserCanAccessDepartment @userId, department
    return TRS.SemesterDepartmentDetail.find
      department: department
      semester: semester

TRS.SemesterDepartmentDetail.allow
  insert: UserIsAdmin
  update: UserIsAdmin
  remove: UserIsAdmin

Meteor.publish 'admins', ->
  TRS.Admins.find()

TRS.Admins.allow
  insert: ->true
  update: ->true
  remove: UserIsAdmin

Meteor.methods
  upsertAdmins: (adminsArray) ->
    console.log 'New admins:'
    console.log adminsArray
    if UserIsAdmin @userId
      return TRS.Admins.upsert {}, {$set: {admins: adminsArray} }
  
Meteor.publish 'dropDeadChanges', (department, semester) ->
  TRS.DropDeadChanges.find
    department: department
    semester: semester


