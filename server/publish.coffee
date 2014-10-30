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
    s = TRS.FacultyAllocations.simpleSchema()._schema
    #console.log s
    l =
      if s[fieldNames[0]]? and s[fieldNames[0]]['label']?
        s[fieldNames[0]]['label']
      else
        fieldNames[0]
    m =
      if modifier['$set']?
        'changed '+l+' of '+doc.name
      else if modifier['$push']?
        'added to '+l+' of '+doc.name
    console.log m
    TRS.DropDeadChanges.insert
      department: doc.department
      semester: doc.semester
      userId: userId
      username: Meteor.users.findOne(userId).username
      docId: doc._id
      timestamp: new Date()
      fieldNames: fieldNames
      message: m
    return true
  remove: (userId, doc) -> true

Meteor.publish 'semesterDepartmentDetail', (department, semester) ->
  if UserCanAccessDepartment @userId, department
    depsem = TRS.SemesterDepartmentDetail.find
      department: department
      semester: semester

    if depsem.count() > 0
      return depsem
      
    TRS.SemesterDepartmentDetail.insert
      department: department
      semester: semester
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
  
Meteor.publish 'dropDeadChanges', (department, semester) ->
  console.log 'publishing changelog'
  TRS.DropDeadChanges.find
    department: department
    semester: semester
    timestamp: {$gte: new Date(Date.now() - 1)}
  ,
    limit: 3
    sort: {timestamp: -1}

Meteor.publish 'changelog', (department, semester) ->
  TRS.DropDeadChanges.find
    department: department
    semester: semester


