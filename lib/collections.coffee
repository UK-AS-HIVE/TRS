
ValidRanks =
  ['Full',
   'Professor',
   'Assoc',
   'Assist',
   'Lecturer',
   'PostDoc',
   'FTI',
   'PTI',
   'GA',
   'TA',
   'RA']

@Semesters = new Meteor.Collection2 'semesters',
  schema: new SimpleSchema
    semester:
      type: String
      label: 'Semester name'
      max: 200
    dropdead:
      type: String
      label: 'Drop-dead date'
      optional: true
    
@Departments = new Meteor.Collection2 'departments',
  schema: new SimpleSchema
    department:
      type: String
      label: 'Department name'
    chairDMusers:
      type: [String]
      label: 'Usernames of authorized editors for this department'
      optional: true
  
@FacultyAllocations = new Meteor.Collection2 'allocations',
  schema: new SimpleSchema
    name:
      type: String
      label: 'Name'
    semester:
      type: String
      label: 'Semester of allocation'
    department:
      type: String
      label: 'Department of allocation'
    rank:
      type: String
      allowedValues: ValidRanks
      optional: true
    ukid:
      type: String
      optional: true
    buyout:
      type: Boolean
      optional: true
    pay_amount:
      type: String
      optional: true
    notes:
      type: String
      optional: true
    'courses.$.prefix':
      type: String
      label: 'Course Prefix'
      max: 4
    'courses.$.number':
      type: String
      label: 'Course Number'
      max: 4
    'courses.$.credits':
      type: Number
      max: 4
    'courses.$.sections':
      type: String
      label: 'Sections'
      optional: true
    lines:
      type: Object
      optional: true
    'lines.GA':
      type: String
      optional: true
    'lines.TA':
      type: String
      optional: true
    'lines.RA':
      type: String
      optional: true
    'lines.PTI':
      type: String
      optional: true
    'lines.FTI':
      type: String
      optional: true



@SemesterDepartmentDetail = new Meteor.Collection2 'semesterDepartmentDetail',
  schema: new SimpleSchema
    semester:
      type: String
      label: 'Semester of allocation'
    department:
      type: String
      label: 'Department of allocation'
    funding:
      type: Number
      label: 'Approved funding'
      optional: true
    comments:
      type: String
      label: 'Comments pertaining to this department and semester'
      optional: true
    
  
@Admins = new Meteor.Collection2 'admins',
  schema: new SimpleSchema
    admins:
      type: [String]
      label: 'List of usernames who have admin privileges'


