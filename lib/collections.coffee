@Semesters = new Meteor.Collection 'semesters'
@Departments = new Meteor.Collection 'departments'
@FacultyAllocations = new Meteor.Collection 'allocations'
@SemesterDepartmentDetail = new Meteor.Collection 'semesterDepartmentDetail'
@Admins = new Meteor.Collection 'admins'

TRS = @

Meteor.methods
  upsertAdmins: (adminsArray) ->
    console.log 'New admins:'
    console.log adminsArray
    TRS.Admins.upsert {}, {$set: {admins: adminsArray} }
