TRS = @

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
   'RA',
   'Fellow']

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
  transform: (doc) ->
    doc.payAmount = 0
    if doc.rank? and ['GA','TA','RA','FTI','PTI'].indexOf(doc.rank) > -1
      depsem = TRS.SemesterDepartmentDetail.findOne {semester: doc.semester, department: doc.department}, {fields: {breakdown: 1}}
      if depsem?
        _.each doc.lines, (v, k) ->
          standard = _.findWhere depsem.breakdown, {rank: k}
          doc.payAmount += fractionToFloat(v) * sanitizePayAmount(standard.rate)
      doc.payAmount += sanitizePayAmount doc.pay_amount
      doc.payAmount = doc.payAmount.toFixed(2)
    else
      doc.payAmount = 0.00.toFixed(2)
    return doc
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
      label: 'UKID'
    buyout:
      type: Boolean
      optional: true
    buyoutPercent:
      type: Number
      optional: true
      min: 0
      max: 100
      label: 'buyout %'
    courseRelease:
      type: Boolean
      optional: true
      label: 'course release'
    courseReleaseAmount:
      type: Number
      optional: true
      min: 0
      label: 'amount of course release'
    overload:
      type: Boolean
      optional: true
    overloadAmount:
      type: String
      optional: true
      label: 'overload amount'
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
      min: 0
      max: 5
    'courses.$.sections':
      type: String
      label: 'Sections'
      optional: true
    lines:
      type: Object
      optional: true
      blackbox: true

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
    breakdown:
      type: [Object]
      label: 'Funding lines'
      optional: true
    'breakdown.$.lines':
      type: Number
      label: 'Number of lines'
      optional: true
    'breakdown.$.rank':
      type: String
      #allowedValues: ['GA','TA','RA','PTI','FTI']
      label: 'Rank'
      optional: true
    'breakdown.$.rate':
      type: String
      label: 'Rate per semester for this rank'
      optional: true
    
  
@Admins = new Meteor.Collection2 'admins',
  schema: new SimpleSchema
    admins:
      type: [String]
      label: 'List of usernames who have admin privileges'

@DropDeadChanges = new Meteor.Collection2 'dropDeadChanges',
  schema: new SimpleSchema
    department:
      type: String
    semester:
      type: String
    username:
      type: String
    userId:
      type: String
    docId:
      type: String
    timestamp:
      type: Date
    fieldNames:
      type: [String]
      optional: true
    message:
      type: String
      optional: true
