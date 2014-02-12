TRS = @

# Utility functions
UserIsAdmin = (userId) ->
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
      return TRS.Departments.find {}
    return TRS.Departments.find { chairDMusers: user.username }

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
  insert: UserIsAdmin
  update: UserIsAdmin
  remove: UserIsAdmin

Meteor.methods
  upsertAdmins: (adminsArray) ->
    console.log 'New admins:'
    console.log adminsArray
    if UserIsAdmin @userId
      return TRS.Admins.upsert {}, {$set: {admins: adminsArray} }

