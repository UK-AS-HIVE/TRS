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
      allowedValues: ['Full', 'Professor', 'Assoc', 'Assist', 'Lecturer', 'PostDoc', 'PTI', 'GradStudent']
      optional: true
    buyout:
      type: String
      optional: true
    pay_amount:
      type: String
      optional: true
    par:
      type: Date
      label: 'Date PAR Submitted'
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
    comments:
      type: String
      label: 'Comments pertaining to this department and semester'
    
  
@Admins = new Meteor.Collection2 'admins',
  schema: new SimpleSchema
    admins:
      type: [String]
      label: 'List of usernames who have admin privileges'


