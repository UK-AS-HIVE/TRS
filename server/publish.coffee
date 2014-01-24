TRS = @

# Utility function
UserCanAccessDepartment = (userId, department) ->
  user = Meteor.users.findOne {_id: userId}
  if user?
    if TRS.Departments.findOne { chairDMusers: user.username, department: department }
      return true
  return false

Meteor.publish 'semesters', ->
  TRS.Semesters.find()

Meteor.publish 'departments', ->
  if @userId
    user = Meteor.users.findOne {_id: @userId}
    return TRS.Departments.find { chairDMusers: user.username }

Meteor.publish 'allocations', (department, semester) ->
  if UserCanAccessDepartment @userId, department
    return TRS.FacultyAllocations.find
      department: department
      semester: semester

Meteor.publish 'semesterDepartmentDetail', (department, semester) ->
  if UserCanAccessDepartment @userId, department
    return TRS.SemesterDepartmentDetail.find
      department: department
      semester: semester

