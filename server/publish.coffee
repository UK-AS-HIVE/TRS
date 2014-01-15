TRS = @

Meteor.publish 'semesters', ->
  TRS.Semesters.find()

Meteor.publish 'departments', ->
  TRS.Departments.find()

Meteor.publish 'allocations', ->
  TRS.FacultyAllocations.find()

Meteor.publish 'semesterDepartmentDetail', ->
  TRS.SemesterDepartmentDetail.find()

